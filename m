From: Mark Lord <lkml@rtr.ca>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 18:51:28 -0500
Message-ID: <4751F380.7040309@rtr.ca>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>	<20071201192341.6750fbdb@the-village.bc.nu>	<20071201113815.5df0960a@freepuppy.rosehill>	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com> <4751C238.6010609@rtr.ca>	<20071201122926.5c887588@laptopd505.fenrus.org>	<4751DC3C.1050606@rtr.ca> <m1tzn23t6k.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([76.10.145.34]:1243 "EHLO mail.rtr.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbXLAXva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 18:51:30 -0500
In-Reply-To: <m1tzn23t6k.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Mark Lord <lkml@rtr.ca> writes:
> 
>> Arjan van de Ven wrote:
>>> On Sat, 01 Dec 2007 15:21:12 -0500
>>> Mark Lord <lkml@rtr.ca> wrote:
>>>
>>>> Eric W. Biederman wrote:
>>>>> Stephen Hemminger <shemminger@linux-foundation.org> writes:
>>>>> Sure.  We keep the updated dev_get_by_XXXX that takes a network
>>>>> namespace parameter.
>>>> ..
>>>>
>>>> And what should code be passing in when "# CONFIG_NET_NS is not set" ?
>>> network drivers probably really really don't want to call
>>> dev_get_by_XXX...
>> ..
>>
>> Fine.  But all of them want to call sk_alloc(),
> 
> network drivers should be calling sk_alloc less then they should
> call dev_get_by_XXXX.  Only protocols call sk_alloc.
..

I think I saw some bridge code that calls it, too.
Regardless, it's EXPORT_SYMBOL(), but now unusable
due to the GPL-only symbol "init_net".

Meanwhile, you are avoiding answering the question:

>>>> And what should code be passing in when "# CONFIG_NET_NS is not set" ?
..

>> and many want to do register_netdev().
> 
> I haven't even touched register_netdev.
..

Bull-pucky.  Somebody did:

> @@ -3361,6 +3595,8 @@ int register_netdevice(struct net_device *dev)
> 
>         /* When net_device's are persistent, this will be fatal. */
>         BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
> +       BUG_ON(!dev->nd_net);
> +       net = dev->nd_net;
> 
>         spin_lock_init(&dev->queue_lock);
>         spin_lock_init(&dev->_xmit_lock);
..

That new BUG_ON() line complains if nd_net has not been initialized,
and the only thing I see drivers putting there is GPL-only "&init_net".

>> So what should they be using there ?
> 
> What are you having problems with?
..

Avoiding the question again there, too.

I personally am not having problems with anything.
But I noticed the API change, and would like somebody to fix it.
Any of the three ways (or a fourth, if you've got one) might do.

Cheers
