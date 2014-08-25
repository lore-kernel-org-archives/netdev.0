From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Mon, 25 Aug 2014 22:45:19 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D1C2BEF0A@eusaamb103.ericsson.se>
References: <20140823.132811.751469424156827125.davem@davemloft.net>
	<20140823.213839.1953243016141233125.davem@davemloft.net>
	<CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
 <20140825.153146.2165451041039058085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"edumazet@google.com" <edumazet@google.com>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>,
	"cwang@twopensource.com" <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg20.ericsson.net ([198.24.6.45]:52129 "EHLO
	usevmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbaHYWpV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:45:21 -0400
In-Reply-To: <20140825.153146.2165451041039058085.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of David Miller
> Sent: August-25-14 6:32 PM
> To: cwang@twopensource.com
> Cc: netdev@vger.kernel.org; therbert@google.com; jhs@mojatatu.com;
> hannes@stressinduktion.org; edumazet@google.com;
> jeffrey.t.kirsher@intel.com; rusty@rustcorp.com.au
> Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
> 
> From: Cong Wang <cwang@twopensource.com>
> Date: Mon, 25 Aug 2014 15:21:00 -0700
> 
> > When I tried to unify the list management of SKB's, I was surprised to
> > see there are still some places relying on skb->next and skb->prev to
> > be the head of the skb struct, since nowadays we have list API's, they
> > still play some magic on these pointers (sctp and tipc IIRC). This is

I am not aware of any such assumptions in TIPC.  For me you can go ahead
with this.

Regards
///jon


> > why I gave up, maybe it's time to revise this again.
> 
> I think SCTP should be OK, and yes I do remember that protocol being one of
> the last subsystems making such SKB list pointer assumptions.
> 
> It was using list_*() operations on sk_buff objects or something like that.
> 
> > Talking about skb->next, fortunately we do gso segmentation after
> > going out of qdisc queues, otherwise it's scary to play with these
> > pointers at same time. I think all queues of SKB's are either using
> > just ->next or both ->prev and ->next.
> 
> It occurs to me that perhaps the thing to do is to pass sk_buff ** to
> dev_hard_start_xmit().
> 
> If it really is important to free the original GSO skb after the segmented parts,
> we can run that as part of the destructor of the final segment.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
