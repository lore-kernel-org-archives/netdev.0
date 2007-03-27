From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [SK_BUFF]: Introduce skb_copy_from_linear_data{_offset}
Date: Tue, 27 Mar 2007 23:24:04 +0200
Message-ID: <46098B74.8060404@trash.net>
References: <20070327194148.GC20303@ghostprotocols.net>	 <20070327.140749.106434705.davem@davemloft.net> <39e6f6c70703271422i3881fc6bw18480e8f1b553e27@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34899 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965452AbXC0VZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:25:19 -0400
In-Reply-To: <39e6f6c70703271422i3881fc6bw18480e8f1b553e27@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> On 3/27/07, David Miller <davem@davemloft.net> wrote:
> 
>> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
>> Date: Tue, 27 Mar 2007 16:41:48 -0300
>>
>> > +static inline void skb_move_linear_data(const struct sk_buff *skb,
>> > +                                     const int from_offset,
>> > +                                     const int to_offset,
>> > +                                     const unsigned int len)
>> > +{
>> > +     memcpy(skb->data + to_offset, skb->data + from_offset, len);
>> > +}
>> > +
>>
>> What do you intend to use this for?  There are no users in
>> your patch, and I'd be fearful of overlapping cases (which
>> ought to be common for anything using this) which therefore
>> would require use of memmove() instead of memcpy().
>>
>> How about we just leave out interfaces until we have a use
>> case?
> 
> 
> I don't want to intend anything with this, was just a brain fart, a
> failed attempt to convince me that this was needed, I apologise for
> letting this sleep thru, will remove and resubmit, ok?


nf_nat_helper.c:mangle_content() could make use of this, but it
would need memmove. Something to do this with non-linear packets
would be even cooler :)
