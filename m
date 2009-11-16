From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: factorize rt_do_flush for batch device unregistering
Date: Mon, 16 Nov 2009 23:15:25 +0100
Message-ID: <4B01CEFD.4070908@gmail.com>
References: <200911162308.59730.opurdila@ixiacom.com> <4B01C507.9050908@gmail.com> <200911170003.44099.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50204 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbZKPWPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 17:15:22 -0500
In-Reply-To: <200911170003.44099.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Monday 16 November 2009 23:32:55 you wrote:
>=20
>>> @@ -5374,6 +5395,9 @@ EXPORT_SYMBOL(unregister_netdevice_queue);
>>>   *	unregister_netdevice_many - unregister many devices
>>>   *	@head: list of devices
>>>   *
>>> + *	WARNING: This function modifies the list. It may change the ord=
er of
>>> the + *	elements in the list. However, you can assume it does not a=
dd or
>>> delete + *	elements to/from the list.
>> Sorry I dont understand this comment
>>
>=20
> The  list passed to unregister_netdevice_many(), as the "head" parame=
ter, may=20
> be altered, e.g. order may change between the elements.
>=20
> That is because we temporarily move the items from the list to the=20
> rt_flush_list for the flush. When we add the items back they may not =
be added in=20
> the same place.
>=20

Ah, I got it now, confusion is that comment makes more sense for
rollback_registered_many() because when reading unregister_netdevice_ma=
ny()
it is clear it doesnt change the list...

void unregister_netdevice_many(struct list_head *head)
{
        struct net_device *dev;

        if (!list_empty(head)) {
                rollback_registered_many(head);
                list_for_each_entry(dev, head, unreg_list)
                        net_set_todo(dev);
        }
}


