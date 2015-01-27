From: Tom Herbert <therbert@google.com>
Subject: Interaction between GSO and TSQ for single TCP stream
Date: Tue, 27 Jan 2015 11:57:29 -0800
Message-ID: <CA+mtBx8QSg+3VSiDgY6iqiJaQgScSd9FP-uxH8S5zGGv7tN1Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:51012 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932674AbbA0T5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 14:57:30 -0500
Received: by mail-ie0-f179.google.com with SMTP id x19so17418277ier.10
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 11:57:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

I am looking at why we are unable to achieve line rate throughput with
a single connection using UDP encapsulation that supports GSO/GRO. I
discovered that even for a non-encpasulated TCP connection I'm not
able to get line rate using GSO/GRO (but do with TSO/LRO). There seems
to be some interaction between TSQ and GSO. Setting
tcp_limit_output_bytes to 1000000 gets single connection up to line
rate for both native and encapsulated TCP.

Some data:

- netperf TCP_STREAM for a single connection no encapsulation
  Using TSO/LRO
    9412.44 Gbps
  Using GSO/GRO (ethtool -K eth0 gso on gro on tso off lro off)
    9286.08 Gbps
  Using GSO/GRO with larger limit (echo 1000000 >
/proc/sys/net/ipv4/tcp_limit_output_bytes)
    9412.75

- netperf TCP_STREAM for a single connection for GUE-IPIP encapsulation with RCO
  Using GSO/GRO
    8842.89 Gbps
  Using GSO/GRO with larger limit (echo 1000000 >
/proc/sys/net/ipv4/tcp_limit_output_bytes)
    9143.99 Gbps

Any ideas on how to address this?

Thanks,
Tom
