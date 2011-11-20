From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: skb->tstamp == 0.00000 ?
Date: Sun, 20 Nov 2011 18:15:14 +0100
Message-ID: <4EC935A2.6020200@hartkopp.net>
References: <CAJX4=r1nz4Wq00tmJKUsJNLb41Bh4=-V1ixLcS05mXm0tpek9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felipe Dias <felipediassss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:35973 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298Ab1KTRPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 12:15:35 -0500
In-Reply-To: <CAJX4=r1nz4Wq00tmJKUsJNLb41Bh4=-V1ixLcS05mXm0tpek9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.11.2011 22:18, Felipe Dias wrote:

> Hi..
> 
> Please let me know if this isnt right list to this kind of question.
> 
> I'm registering a new protocol handler with dev_add_pack. I would like
> to know only the difference between timestamp on skb->tstamp and the
> time of reception by my module.


Hello Felipe,

tstamp is a ktime_t type, which is a timestamp in nanosecs

http://lxr.linux.no/#linux+v3.1.1/include/linux/ktime.h#L28

The value in the skbuff

http://lxr.linux.no/#linux+v3.1.1/include/linux/skbuff.h#L347

is usually set at PDU reception time -> see netif_rx().

http://lxr.linux.no/#linux+v3.1.1/net/core/dev.c#L2879

where net_timestamp_check(skb) is executed which usually sets the timestamp
when timestamping is activated.

So when your netdevice creates a proper skbuff (e.g. using skb_alloc) the
timestamp is set to zero and therefore set to the receive time in
net_timestamp_check().


> 
> So I do:
> ----
> struct timeval time_skb, time_module;
> do_gettimeofday(&time_module):
> skb_get_timestamp(skb, &time_skb);
> ---
> 
> And time_skb.tv_sec and time_skb.tv_usec are equal to 0;
> 
> I'm doing some wrong ?


Hm, i don't see, why you convert ktime_t to timeval.

You better work on skb->tstamp with the ktime functions directly, e.g. with
skb_get_ktime().

I hope this gives you a bit more insight in skb->tstamp - even if i don't know
your problem in detail %-)

Regards,
Oliver
