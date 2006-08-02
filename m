From: Amin Azez <azez@ufomechanic.net>
Subject: Re: [patch] RFC: matching interface groups
Date: Wed, 02 Aug 2006 10:01:05 +0100
Message-ID: <44D069D1.4040702@ufomechanic.net>
References: <1154452209.6395.77.camel@bzorp.balabit>	 <20060801184655.GA7452@linuxace.com>	 <20060801191805.GA28649@zion.homelinux.com> <1154502269.6241.11.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Phil Oester <kernel@linuxace.com>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1.secure-linux-server.com ([207.44.172.97]:10430 "EHLO
	server1.secure-linux-server.com") by vger.kernel.org with ESMTP
	id S1750730AbWHBJBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 05:01:32 -0400
To: Balazs Scheidler <bazsi@balabit.hu>
In-Reply-To: <1154502269.6241.11.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Balazs Scheidler wrote, On 02/08/06 08:04:
> On Tue, 2006-08-01 at 21:18 +0200, Sven Schuster wrote:
>> as this would require the complete chain (say, INPUT or
>> OUTPUT) to be "downloaded" to userspace, modified and then again
>> "uploaded" to the kernel. At least until iptables redesign to
>> allow replacement/insertion/deletion of single rules is completed
>> which if started at all will take quite some more time :-)
> 
> Iptables operates on a per-table basis, so it is not only the INPUT or
> OUTPUT chain that needs to be down and uploaded, but the whole filter
> table.
> 
> And in addition, in my humble opinion the iptables ruleset should be up
> to the user to maintain, once some kind of automatism starts to
> add/remove rules on the fly, it becomes more difficult to do other
> changes to add independent rules to the table. For example the user
> needs to save the current ruleset using iptables-save, then modify the
> resulting file, and then load it again. If the ruleset is generated as
> it happens with a lot of tools, this might not be so easy.
> 

Even without this scenario it is not easily safe; if two interfaces
chanegd at the same time, two copies of iptables would be downloaded to
user space, both modified differently and the last one to be uploaded
would win, the other one loosing its changes.

This has bitten me and is one of my reasons for liking ipt_condition

Sam
