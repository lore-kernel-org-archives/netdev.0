From: Andy Lutomirski <luto@amacapital.net>
Subject: Why can't we SNAT (or inverse DNAT) in PREROUTING?
Date: Fri, 26 Jun 2015 12:51:03 -0700
Message-ID: <CALCETrWRv5S_X=MQRGwO-NR+XrQc2o-EnooHFN0V41xqJEY8sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:35303 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbFZTvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 15:51:24 -0400
Received: by lagi2 with SMTP id i2so69848783lag.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 12:51:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's quite clear to me why NAT rules that rewrite the destination
address have to happen before routing -- the kernel needs to do that
to route the packets to their destination.

It's much less clear to me why the kernel insists on rewriting source
addresses after routing.  Certainly it makes rp_filter work better,
but it makes policy routing very messy when NAT is in play.  I have a
system with two internet connections, and I use policy routing* to
choose which outgoing connection to use based on source address.  This
is completely broken when the source address is rewritten by NAT
*after* routing.

Could we add some option to do SNAT and inverse DNAT before routing?

* Grr, IPV6_SUBTREES is so much nicer than policy routing, but even
IPV4_SUBTREES wouldn't help here.

--Andy
