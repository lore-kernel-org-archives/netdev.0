From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] veth: don't assign a qdisc to veth
Date: Fri, 03 Oct 2014 14:56:04 -0700 (PDT)
Message-ID: <20141003.145604.344775445146119193.davem@davemloft.net>
References: <CAHA+R7PMkNefxottnNOq+xhRVW_n+SXQxZYFXoNY1b_xEjWm5g@mail.gmail.com>
	<20141003223816.6c56e6d8@redhat.com>
	<1412369519.17245.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, cwang@twopensource.com, netdev@vger.kernel.org,
	jpirko@redhat.com, mpatel@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155AbaJCVyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 17:54:02 -0400
In-Reply-To: <1412369519.17245.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Oct 2014 13:51:59 -0700

> On Fri, 2014-10-03 at 22:38 +0200, Jesper Dangaard Brouer wrote:
>> On Fri, 3 Oct 2014 09:53:16 -0700
>> Cong Wang <cwang@twopensource.com> wrote:
>> 
>> > On Fri, Oct 3, 2014 at 3:48 AM, Jesper Dangaard Brouer
>> > <brouer@redhat.com> wrote:
>> > > The veth driver is a virtual device, and should not have assigned
>> > > the default qdisc.  Verified (ndo_start_xmit) veth_xmit can only
>> > > return NETDEV_TX_OK, thus this should be safe to bypass qdisc.
>> > >
>> > > Not assigning a qdisc is subtly done by setting tx_queue_len to zero.
>> > >
>> > 
>> > Huh?? Maybe your $subject is too misleading, but we do use HTB
>> > on veth, this will break our code since we will have to set tx_queue_len
>> > after your patch, no?
>> 
>> No, you HTB setup should still work.
> 
> Unfortunately no....
> 
> Default htb classes are pfifo, and this uses device txqueuelen as
> default limit.
> 
> So your change should have been done years ago.
> 
> Now its too late as it can break existing user scripts.

Agreed, this change cannot be made.
