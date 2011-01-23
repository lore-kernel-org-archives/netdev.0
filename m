From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v4] net-next-2.6: Allow ethtool to set interface in
 loopback mode.
Date: Sun, 23 Jan 2011 09:12:42 -0800
Message-ID: <AANLkTimdNjUrNJ0yhg0VvK2TdM6THT=TieXjLbsMNRBB@mail.gmail.com>
References: <1294187401-4662-1-git-send-email-maheshb@google.com>
	<1295655836-23421-1-git-send-email-maheshb@google.com>
	<1295750153.4117.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:13951 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab1AWRMp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 12:12:45 -0500
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p0NHCibc031609
	for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 09:12:44 -0800
Received: from bwz16 (bwz16.prod.google.com [10.188.26.16])
	by hpaq12.eem.corp.google.com with ESMTP id p0NHCKLt011646
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 09:12:42 -0800
Received: by bwz16 with SMTP id 16so3087856bwz.14
        for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 09:12:42 -0800 (PST)
In-Reply-To: <1295750153.4117.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 22, 2011 at 6:35 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2011-01-21 at 16:23 -0800, Mahesh Bandewar wrote:
>> This patch enables ethtool to set the loopback mode on a given inter=
face.
>> By configuring the interface in loopback mode in conjunction with a =
policy
>> route / rule, a userland application can stress the egress / ingress=
 path
>> exposing the flows of the change in progress and potentially help de=
veloper(s)
>> understand the impact of those changes without even sending a packet=
 out
>> on the network.
>>
>> Following set of commands illustrates one such example -
>> =A0 =A0 =A0 a) ip -4 addr add 192.168.1.1/24 dev eth1
>> =A0 =A0 =A0 b) ip -4 rule add from all iif eth1 lookup 250
>> =A0 =A0 =A0 c) ip -4 route add local 0/0 dev lo proto kernel scope h=
ost table 250
>> =A0 =A0 =A0 d) arp -Ds 192.168.1.100 eth1
>> =A0 =A0 =A0 e) arp -Ds 192.168.1.200 eth1
>> =A0 =A0 =A0 f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
>> =A0 =A0 =A0 g) sysctl -w net.ipv4.conf.all.accept_local=3D1
>> =A0 =A0 =A0 # Assuming that the machine has 8 cores
>> =A0 =A0 =A0 h) taskset 000f netserver -L 192.168.1.200
>> =A0 =A0 =A0 i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 1=
92.168.1.200 -l 30
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> [...]
>
> If this version has been revised, you can't claim I reviewed it!
> If it's a repost of an earlier version, you should say so.
There were no code changes made since you reviewed last. I made some
formatting changes only and that's why I thought it would be
appropriate to put your name there.
>
> I thought we agreed that loopback could be treated as a flag, anyway.
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
