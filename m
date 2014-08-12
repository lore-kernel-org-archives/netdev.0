From: =?UTF-8?Q?Bj=C3=B8rnar_Ness?= <bjornar.ness@gmail.com>
Subject: Fwd: about Bug 14007 - iproute2: socket lookup after..
Date: Tue, 12 Aug 2014 21:52:27 +0200
Message-ID: <CAJO99TkWfy8tDGJ7uEPM3Wahdypxdqi=yW4tJM9m_C6Y9LbR0g@mail.gmail.com>
References: <CAJO99TmhSnGNxhdkMxbipv7nLSCJ0_SsgSbCoEhhP5g1gUpwAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:65091 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755339AbaHLTw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 15:52:29 -0400
Received: by mail-lb0-f178.google.com with SMTP id c11so7362162lbj.23
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 12:52:28 -0700 (PDT)
In-Reply-To: <CAJO99TmhSnGNxhdkMxbipv7nLSCJ0_SsgSbCoEhhP5g1gUpwAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys,

While experimenting with some not-so-common network setup, I came
across the same
issue as mentioned in bug (14007) from 5 years ago. This bug was
closed as "INVALID",
without any explanation, and I also am unable to find relevant
documents on this topic.

What I want to do is something like this:

sysctl -w net.ipv4.ip_nonlocal_bind=1

nc -l 1.2.3.4 1234 &

ip rule del pref 0
ip rule add pref 100 table local
ip route add table 255 local 1.2.3.4/32<http://1.2.3.4/32> dev lo scope host
ip rule add pref 50 fwmark 0xff table 255


When I try to connect to 1.2.3.4 1234 or ping 1.2.3.4 I get "invalid argument"

What is the cause of this, and how can I accomplish what I want?

adding same route to local table does what I want.

-- 
Bj(/)rnar
