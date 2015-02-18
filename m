From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we use RX queue mapping for TX?
Date: Wed, 18 Feb 2015 15:57:17 -0800
Message-ID: <CAHA+R7PbLRw-oA4v9ivZ0s-++ALx99zddJLDqDoemyBTc2XZ1g@mail.gmail.com>
References: <CAHA+R7MXF-KHZ3aeBwwshSYDswKwrjhbMJQ=+Hfj3gZJq70dXQ@mail.gmail.com>
	<CAHA+R7PdG+jDqFA1jDFzHtkrxqLEZdtj1w5QyrdYMO4fX6+A1w@mail.gmail.com>
	<CAHA+R7OVHgwQBM200UZDKiw5eypuzhWj=B4E3MRkOK3yViZDCQ@mail.gmail.com>
	<1424301248.4942.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:38722 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbbBRX5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 18:57:18 -0500
Received: by iecrd18 with SMTP id rd18so5589990iec.5
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 15:57:18 -0800 (PST)
In-Reply-To: <1424301248.4942.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2015 at 3:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-02-18 at 14:11 -0800, Cong Wang wrote:
>> On Wed, Feb 18, 2015 at 1:18 PM, Cong Wang <cwang@twopensource.com> wrote:
>> >
>> > 2) This breaks the queue mapping specified by an skbedit action,
>> > since for TX queues the index starts with 0 while for RX it starts with 1
>> > (for some reason I don't see yet). There is at least a mismatch.
>>
>> So queue 0 is reserved for TX, at least for bonding queue mapping.
>
> It seems you missed that bonding ndo_select_queue() is rather special.
>
>

I am aware of it. I even would guess (means not digging the history)
skb_edit was invented for bonding queue mapping, since I don't see it
even works as a general TC action on the physical interface. We pick
the tx queue prior to getting the Qdisc, therefore too late to set
skb->queue_mapping to specify a hardware TX queue. This is
another story I planned to bring it up to David.

However, this still doesn't seem to be a reason to break people who
don't use bonding at all? At least we just want to map skb's to different
hardware TX queues by setting skb->queue_mapping (before
dev_queue_xmit() of course) and sysfs reports the queues starting with
index 0. This is why I complain. :)
