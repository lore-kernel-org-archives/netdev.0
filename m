From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: ebtables on a stick
Date: Thu, 1 Dec 2011 08:39:07 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A048F8@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <4ED566A8.2000108@ziu.info> <925A849792280C4E80C5461017A4B8A2A048F6@mail733.InfraSupportEtc.com> <20111201071456.GJ589422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Lamparter" <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:27396 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665Ab1LAOjI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 09:39:08 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well now, this is interesting.  Hopefully the emailer won't garble
below.  

3.4.2.129 is me.  I sent some pings from here to my public host.
Listening on eth0 on the firewall, here they come.  But the interesting
part is trying again, this time listening on eth1 on the firewall.  I
forwarded them! So why no echo reply? That makes me wonder if I did
something dumb on the test host I set up.  I'll probably hop in the car
and drive over there and take a look.  

[root@ehac-fw2011 firewall-scripts]#
[root@ehac-fw2011 firewall-scripts]# /usr/sbin/tcpdump -i eth0 net
3.4.2.128/27 and port not 22 -nn
tcpdump: verbose output suppressed, use -v or -vv for full protocol
decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
08:18:29.653384 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
72, length 40
08:18:34.201405 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
73, length 40
08:18:39.209183 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
74, length 40
08:18:44.202242 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
75, length 40
^C
4 packets captured
4 packets received by filter
0 packets dropped by kernel
[root@ehac-fw2011 firewall-scripts]# /usr/sbin/tcpdump -i eth1 net
3.4.2.128/27 and port not 22 -nn
tcpdump: verbose output suppressed, use -v or -vv for full protocol
decode
listening on eth1, link-type EN10MB (Ethernet), capture size 65535 bytes
08:18:58.871185 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
76, length 40
08:19:03.719756 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
77, length 40
08:19:08.727342 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
78, length 40
08:19:13.704391 IP 3.4.2.129 > 1.2.115.157: ICMP echo request, id 1, seq
79, length 40
^C
4 packets captured
4 packets received by filter
0 packets dropped by kernel
[root@ehac-fw2011 firewall-scripts]#


Or - easier than hopping in the car - I did set it up to allow RDP in.
I wonder . . .

Yup, I can do an RDP session into it from here.  And sure enough, the
Windows personal firewall is turned on.  Turning it off - holy moley,
round trip pings from here!  And now I can also ping google from that
test workstation.  

I wonder what's different this morning?  A bunch of firewall conntrack
entries would have expired by now.  I was changing rules fast and
furious last night, maybe there were some stale conntrack entries that
messed with my head.  But this morning it's working as expected.

Must be an important project, otherwise it wouldn't give me all this
trouble.

- Greg
