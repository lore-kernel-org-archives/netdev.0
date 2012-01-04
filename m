From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Wed, 4 Jan 2012 12:17:18 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201041216010.2645@frira.zrqbmnf.qr>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <201201040949.54985.hans.schillstrom@ericsson.com> <alpine.DEB.2.00.1201041000150.925@blackhole.kfki.hu> <201201041118.18552.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:33641 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755373Ab2ADLRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 06:17:19 -0500
In-Reply-To: <201201041118.18552.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2012-01-04 11:18, Hans Schillstrom wrote:

>On Wednesday 04 January 2012 10:03:49 Jozsef Kadlecsik wrote:
>> On Wed, 4 Jan 2012, Hans Schillstrom wrote:
>> 
>> > On Wednesday 04 January 2012 09:28:05 Jozsef Kadlecsik wrote:
>> > > 
>> > > On Wed, 4 Jan 2012, Hans Schillstrom wrote:
>> > > 
>> > > > In some cases it not desirable to have auto defrag.
>> > > > Ex. in a cluster where packets can arrive on different blades.
>> > > > In that case it is possible to use containers (LXC) and send
>> > > > all fragments to one place where defrag is enabled.
>> > > > 
>> > > > This patch makes it possible to turn off the defrag per network name space,
>> > > > by setting net.netfilter.nf_conntrack_nodefrag to 1.
>> > > > Both IPv4 and IPv6 is effected by this sysctl.
>> > > > Default is 0 which is defrag.
>> > > 
>> > > Conntrack assumes that the packets are defragmented and will drop any 
>> > > unfragmented one. So your patch results packet drops.
>> > 
>> > Hmmm, more work...
>> > > 
>> > > Also, if you want to disable defragmentation then why don't you simply 
>> > > "mark" the packets with the NOTRACK target?
>> > 
>> > I don't think that will work since NF_IP_PRI_CONNTRACK_DEFRAG is -400
>> 
>> Then change NF_IP_PRI_RAW so that it precedes NF_IP_PRI_CONNTRACK_DEFRAG. 
>> The raw table should be made possible to completely override conntack and 
>> defrag is implicit part of the latter.
>> 
>
>An other idea, turn off both conntrack and defrag
>i.e. do like NOTRAC and rename the flag  ?

Or just add a new table - that one we can remove/stash
when I get my xt2 patches out.
