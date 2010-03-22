From: thomas yang <lampsu@gmail.com>
Subject: [iproute2] iproute2 question
Date: Tue, 23 Mar 2010 01:12:57 +0800
Message-ID: <f4f837ab1003221012q37a5e6cdg2aac2aad06b7446e@mail.gmail.com>
References: <f4f837ab1003180202h6b2d5ed0ledd2a24dfd2627df@mail.gmail.com>
	 <20100318085919.05328127@nehalam>
	 <f4f837ab1003182253x12727855k118f7d67115daf23@mail.gmail.com>
	 <20100318232726.47f800e1@nehalam>
	 <f4f837ab1003221011v6657bebx3a741df5c781adf3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f184.google.com ([209.85.216.184]:61261 "EHLO
	mail-px0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494Ab0CVRNA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 13:13:00 -0400
Received: by pxi14 with SMTP id 14so3474138pxi.15
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 10:12:59 -0700 (PDT)
In-Reply-To: <f4f837ab1003221011v6657bebx3a741df5c781adf3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> I want to reduce the packet loss that happens while routers converge
>> after a topology change due to a failure, use precalculated backup
>> table to do rapid failure repair =A0(repair faster than routing daem=
on,
>> fast reroute).
>> I do static routing on my linux routers. =A0When =A0some link =A0fai=
led,
>> =A0I want to =A0use backup tables to route packets. =A0Can iproute2 =
do this?
>
> You could probably kludge something with multiple route tables
> and modifying a single 'ip rule'.
> Something like:
> =A0 http://www.linuxhorizon.ro/iproute2.html
>

I want to use different routing tables =A0with different =A0TOS (or DSC=
P)
e.g.
iptables -t mangle -A PREROUTING -j TOS --set-tos 0x10
=2E..
then,
ip rule add tos 0x10 table 100
ip rule add tos 0x08 table 200
=2E..
but there are only five TOS values =A00x00,0x02,0x04,0x08,0x10. I need
more TOS values.

Does cmd 'ip rule' support DSCP ? (e.g. 'ip rule add dscp 0x11 tables 1=
0')
