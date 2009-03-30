From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge -try4
Date: Mon, 30 Mar 2009 14:40:56 +0200
Message-ID: <20090330124049.GD3438@psychotron.englab.brq.redhat.com>
References: <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090327.003819.234492275.davem@davemloft.net> <49CC85E9.7070903@trash.net> <20090329.135355.109115565.davem@davemloft.net> <49D0B549.3050900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750872AbZC3Mnr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D0B549.3050900@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Mar 30, 2009 at 02:04:25PM CEST, kaber@trash.net wrote:
> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Fri, 27 Mar 2009 08:53:13 +0100
>>
>>> ... an alternative approach
>>> would be to have bonding add FDB entries for all secondary MACs to
>>> make bridging treat them as local.
>>
>> Do you guys foresee any possibility of an alternative implementation
>> any time soon?
>>
>> Otherwise we're just stalling by not putting something into the tree,
>> and as far as I can tell this patch here might as well be it.
>
> Adding bridge FDB entries seems like the best fix. It might
> need some minor ugliness to avoid new dependencies between
> bonding and bridging, but it definitely beats having new hooks
> in the core in my opinion.

Agree with this.
>
> But I have no idea whether Jiri is actually implementing this.

Currently I'm thinking the way. What I have on mind:
I would like to add a list into struct net_device to contain all mac addresses
of the device. I would also like to use similar interface to handle them as
currently is for uc_list and mc_list. However I do not like that these lists are
not using standard list_head but they are propriate lists only for this purpose.
I'm thinking about converting them to use list_head first. Or maybe ignore them
and do the new list for macs in parallel?

Then we can fill this list with macs in bonding driver and let bridge check it
and make fdb entries.
