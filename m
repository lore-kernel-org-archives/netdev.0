From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next-next v4 1/2] net: Use 16bits for inner_*_headers
 fields of struct skbuff
Date: Wed, 22 May 2013 04:32:06 -0700
Message-ID: <1369222326.3301.301.camel@edumazet-glaptop>
References: <1369205836-9407-1-git-send-email-horms@verge.net.au>
	 <1369205836-9407-2-git-send-email-horms@verge.net.au>
	 <alpine.GSO.2.00.1305220923130.11532@git.silcnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, dev@openvswitch.org,
	netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Pekka Riikonen <priikone@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:42229 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608Ab3EVLcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:32:08 -0400
Received: by mail-da0-f46.google.com with SMTP id e20so1093975dak.19
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 04:32:07 -0700 (PDT)
In-Reply-To: <alpine.GSO.2.00.1305220923130.11532@git.silcnet.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 09:25 +0200, Pekka Riikonen wrote:
> On Wed, 22 May 2013, Simon Horman wrote:
> 
> > include/linux/skbuff.h | 63 +++++++-------------------------------------------
> > 1 file changed, 8 insertions(+), 55 deletions(-)
> >
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 2e0ced1..3791615 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -509,9 +509,9 @@ struct sk_buff {
> > 		__u32		reserved_tailroom;
> > 	};
> >
> > -	sk_buff_data_t		inner_transport_header;
> > -	sk_buff_data_t		inner_network_header;
> > -	sk_buff_data_t		inner_mac_header;
> > +	__u16			inner_transport_header;
> > +	__u16			inner_network_header;
> > +	__u16			inner_mac_header;
> > 	sk_buff_data_t		transport_header;
> > 	sk_buff_data_t		network_header;
> > 	sk_buff_data_t		mac_header;
> >
> Why not take one more step and use 16-bit fields for the other header 
> fields too: transport_header, network_header and mac_header?

Thats more risky [1], but definitely worth doing

[1] 
commit 50bceae9bd3569d56744882f3012734d48a1d413
Author: Thomas Graf <tgraf@suug.ch>
Date:   Thu Apr 11 10:57:18 2013 +0000

    tcp: Reallocate headroom if it would overflow csum_start
    
    If a TCP retransmission gets partially ACKed and collapsed multiple
    times it is possible for the headroom to grow beyond 64K which will
    overflow the 16bit skb->csum_start which is based on the start of
    the headroom. It has been observed rarely in the wild with IPoIB due
    to the 64K MTU.
    
    Verify if the acking and collapsing resulted in a headroom exceeding
    what csum_start can cover and reallocate the headroom if so.
    
    A big thank you to Jim Foraker <foraker1@llnl.gov> and the team at
    LLNL for helping out with the investigation and testing.
    
    Reported-by: Jim Foraker <foraker1@llnl.gov>
    Signed-off-by: Thomas Graf <tgraf@suug.ch>
    Acked-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
