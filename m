From: Tom Herbert <therbert@google.com>
Subject: Performance loss with GRO enabled on tunnels
Date: Thu, 26 Jun 2014 17:59:16 -0700
Message-ID: <CA+mtBx9uvD7Ddg4xQxDKxFK395ccEc3YvwhFVZJU9xJvUsAdGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:51831 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaF0A7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 20:59:17 -0400
Received: by mail-ie0-f182.google.com with SMTP id rp18so3864890iec.13
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 17:59:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing quite a performance difference with GRO enabled/disabled on
the tun interface for GRE and IPIP. Physical interface is bnx2x with
lro enable and GRO disabled. Looks like tun interface inherits GRO as
an "always supported SW feature".

200 connection TCP_RR with GRE and no GRO on tun0
  1.06046e+06 tps
  71.06% CPU utilization

With GRO enabled on tun0
  406879 tps
  28.14% CPU utilization

Given CPU utilization is not particularly high, so I would guess
things are being slowed down by something like lock contention.

Generally, I wonder if there's really any value on enabling GRO on the
tunnel interface anyway, seems like GRO is going to be most beneficial
if we do this at the physical device-- if we're aggregating at the
tunnel interface we've already done a lot of processing on the
individual packets.

Tom
