From: Meelis Roos <mroos@linux.ee>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP
 (ARCH=ppc)
Date: Sun, 4 Jun 2006 15:39:35 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0606041528250.2191@math.ut.ee>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
 <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net>
 <Pine.SOC.4.61.0606011002180.13777@math.ut.ee> <447F2787.8010203@trash.net>
 <Pine.SOC.4.61.0606012346350.28838@math.ut.ee> <4480385C.7080405@trash.net>
 <Pine.SOC.4.61.0606021617480.1298@math.ut.ee> <44804379.60808@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:50941 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751309AbWFDMjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2006 08:39:44 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44804379.60808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Please enable DEBUG_IP_FIREWALL_USER in net/netfilter/x_tables.c as well
> and retry. Results of the raw or mangle table would also be interesting
> because they contain a different number of built-in chains.

Sorry it took so long, I was away. Adding this define does not seem to 
do much (table->private->number prints only):

On boot (1 nat rule):
ip_tables: (C) 2000-2006 Netfilter Core Team
Netfilter messages via NETLINK v0.30.
ip_conntrack version 2.4 (1536 buckets, 12288 max) - 224 bytes per conntrack
translate_table: size 632
Finished chain 0
Finished chain 3
Finished chain 4
table->private->number = 4
t->private->number = 4
translate_table: size 800
Bad offset cba528d4

modprobe iptable_nat succeeded in manual modprobe.

modprobe iptable_filter:
translate_table: size 632
Bad offset cbbd910c

modprobe iptable_mangle:
translate_table: size 936
Bad offset cbbd80dc

modprobe iptable_raw:
translate_table: size 480
Bad offset cb8abd44

Retrying ifup and ifdown that tried to do iptables -D and iptables -I:
t->private->number = 4
t->private->number = 4
t->private->number = 4
translate_table: size 800
Bad offset cbbd80dc
t->private->number = 4

And retrying it more (succeeded this time):

t->private->number = 4
t->private->number = 4
translate_table: size 800
Finished chain 0
Finished chain 3
Finished chain 4
ip_tables: Translated table
do_replace: oldnum=4, initnum=4, newnum=5
t->private->number = 5

-- 
Meelis Roos (mroos@linux.ee)
