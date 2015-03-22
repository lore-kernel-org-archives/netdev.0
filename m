From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] bonding work-queues, try_rtnl() &
 notifications
Date: Sat, 21 Mar 2015 22:36:37 -0400 (EDT)
Message-ID: <20150321.223637.2214520794734249959.davem@davemloft.net>
References: <CAF2d9jhMz4Y1ye_ofkgvXyxUJEpNnLrFjMJhHQXKbf6MSS-OVg@mail.gmail.com>
	<20150321.221631.908834228517236497.davem@davemloft.net>
	<CANP3RGeVhFMSvToY7nTu06+eYyscJyHS=uEswnH9Wh=UNfMscQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maheshb@google.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	vfalico@gmail.com, nikolay@redhat.com, netdev@vger.kernel.org,
	edumazet@google.com
To: maze@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbCVCgj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 22:36:39 -0400
In-Reply-To: <CANP3RGeVhFMSvToY7nTu06+eYyscJyHS=uEswnH9Wh=UNfMscQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <maze@google.com>
Date: Sat, 21 Mar 2015 19:23:51 -0700

>> Someone has to do the work, and if the rtnl-owner does it we do not
>> incur all of the overhead the resubmission entails.
>=20
> Are you suggesting:
> - adding a global queue of (function pointer, long arg)
> - changing rtnl_unlock to iterate through the queue calling
> function(arg) before it actually releases the rtnl lock
> ?

Something like that.

> I guess at that point you could even have a generic method
>=20
> void asynch_call_under_rtnl(function, arg) {
>   rtnl_callback_add_to_queue(function,arg)
>   if (rtnl_try_lock())
>     rtnl_unlock();
> }

Right.
