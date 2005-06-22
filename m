From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 15:30:34 -0700 (PDT)
Message-ID: <20050622.153034.107939995.davem@davemloft.net>
References: <20050622.132241.21929037.davem@davemloft.net>
	<42B9DA4D.5090103@cosmosbay.com>
	<42B9E281.1090109@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, leonid.grossman@neterion.com, hadi@cyberus.ca,
        becker@scyld.com, rick.jones2@hp.com, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42B9E281.1090109@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 23 Jun 2005 00:13:21 +0200

> I also found that the memcpy() done to copy the data to the new skb suffers from misalignment.
> 
> This is because of skb_reserve(skbs, 2) that was done on both skb, and memcpy() (at least on x86_64) doing long word copies without checking 
> alignment of source or destination.
> 
> Maybe we could :
>
> 1) make sure both skbs had the same skb_reserve() of 2 (thats not clear because tg3.c mixes the '2' and tp->rx_offset,
> and according to a comment :
> 	rx_offset != 2 iff this is a 5701 card running 
>                                           	in PCI-X mode
>
> 2) and do :
> 
> -	memcpy(copy_skb->data, skb->data, len);
> +	memcpy(copy_skb->data-2, skb->data-2, len+2);
> 
> (That is copy 2 more bytes, but gain aligned copy to speedup memcpy())

Yep, good idea.  Actually, the driver should be using
NET_IP_ALIGN for rx_offset unless it's the 5701 card running
in PCI-X mode case.
