From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next-2.6] vlan: lockless transmit path
Date: Thu, 11 Nov 2010 10:56:13 -0800
Message-ID: <AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com>
References: <1289468520.17691.1018.camel@edumazet-laptop>
	<AANLkTikBkUNfrfSZkoVd1xzisD3jgg5kVUUZC45gNpde@mail.gmail.com>
	<1289497978.17691.1582.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43463 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741Ab0KKS4P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 13:56:15 -0500
Received: by wwb34 with SMTP id 34so188764wwb.1
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 10:56:14 -0800 (PST)
In-Reply-To: <1289497978.17691.1582.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 11, 2010 at 9:52 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 11 novembre 2010 =E0 09:40 -0800, Jesse Gross a =E9crit :
>
>> If we're only allocating a single queue then we should also drop
>> vlan_dev_select_queue() and the netdev_ops that call it. =A0If the
>> underlying device is multiqueue and has its own select_queue functio=
n
>> then it can pick a queue number that is larger than what the vlan
>> device has. =A0The problem will be caught by dev_cap_txqueue() but i=
t's
>> not right and it would also be nice to get rid of half of those
>> netdev_ops.
>
> Hmm, you refer to old kernels dont you ?
>
> My patch is for net-next

Well, I was referring to checked-in code.

>
> The plan is that after last Tom Herbert patches, dev_pick_tx() =A0won=
t
> call do_select_queue() on mono queue device.
>
> http://patchwork.ozlabs.org/patch/70369/

Before Tom's patch, a warning will be generated if a single queue vlan
device is stacked on top of a multiqueue physical device that
implements ndo_select_queue().  After Tom's patch, we avoid the
warning so vlan_dev_select_queue() is merely dead code.  Either way,
what's the benefit in keeping it?

>
>
> This logicaly is a second cleanup patch I believe.

I'm not arguing against your patch, I just think it should go a step fu=
rther.
