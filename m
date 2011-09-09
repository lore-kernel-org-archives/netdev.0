From: Kumar S <ps2kumar@yahoo.com>
Subject: Memory leak in ip_dst_cache
Date: Thu, 8 Sep 2011 22:04:34 -0700 (PDT)
Message-ID: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
Reply-To: Kumar S <ps2kumar@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm3.bullet.mail.sp2.yahoo.com ([98.139.91.73]:27141 "HELO
	nm3.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753148Ab1IIFEf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Sep 2011 01:04:35 -0400
References: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
We are=A0running Linux-2.6.24 kernel on MPC8360. Though forwarding is d=
isabled, when connected to public network we see the system running out=
 of memory and rebooting frequently. After doing some study we found ou=
t slowly "ip_dst-cache" is growing, and doesn't release entries. Intere=
stingly route entries displayed with command "ip route ls cache" show f=
ewer than the active objects listed under "cat /proc/slabinfo | grep ip=
_dst_cache". After doing some study, we could reproduce it in the lab b=
y injecting packets withdifferent source IP addresses. Ideally ageing s=
hould happen, and old entries are supposed to be cleared out, but that =
doesn't happen. We do see one or two entries getting agedout but not al=
l.=20
After some time we did see that "rt_run_flush" kicks in and flushes out=
 the ip_dst_cache. That's why the "ip route ls cache" fewer entries. Bu=
t looks like __chache_free() doesn't get called, that's why these entri=
es are not really released. This results in the leak.
=A0
Any idea what is going wrong here. Is it a known bug?
=A0
Regards
psk
