From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Wed, 4 Jan 2012 10:32:14 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201041030450.23605@frira.zrqbmnf.qr>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <alpine.DEB.2.00.1201040922020.925@blackhole.kfki.hu> <201201040949.54985.hans.schillstrom@ericsson.com> <alpine.DEB.2.00.1201041000150.925@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:32958 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754694Ab2ADJcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 04:32:17 -0500
In-Reply-To: <alpine.DEB.2.00.1201041000150.925@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2012-01-04 10:03, Jozsef Kadlecsik wrote:

>On Wed, 4 Jan 2012, Hans Schillstrom wrote:
>
>> On Wednesday 04 January 2012 09:28:05 Jozsef Kadlecsik wrote:
>> > 
>> > On Wed, 4 Jan 2012, Hans Schillstrom wrote:
>> > 
>> > > In some cases it not desirable to have auto defrag.
>> > > Ex. in a cluster where packets can arrive on different blades.
>> > > In that case it is possible to use containers (LXC) and send
>> > > all fragments to one place where defrag is enabled.
>> > > 
>> > > This patch makes it possible to turn off the defrag per network name space,
>> > > by setting net.netfilter.nf_conntrack_nodefrag to 1.
>> > > Both IPv4 and IPv6 is effected by this sysctl.
>> > > Default is 0 which is defrag.
>> > 
>> > Conntrack assumes that the packets are defragmented and will drop any 
>> > unfragmented one. So your patch results packet drops.
>> 
>> Hmmm, more work...
>> > 
>> > Also, if you want to disable defragmentation then why don't you simply 
>> > "mark" the packets with the NOTRACK target?
>> 
>> I don't think that will work since NF_IP_PRI_CONNTRACK_DEFRAG is -400
>
>Then change NF_IP_PRI_RAW so that it precedes NF_IP_PRI_CONNTRACK_DEFRAG. 
>The raw table should be made possible to completely override conntack and 
>defrag is implicit part of the latter.

We've been there (me in the thread even) - defrag is running before raw,
because otherwise you could not select packets based upon L4 
parameters for non-defrag in the first place:

	-t raw ... -p udp --dport 53 -j CT --notrack

Not that I overly care about whether defrag is before/after raw..
