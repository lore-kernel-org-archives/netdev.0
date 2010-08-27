From: "Yossi Etigin" <yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org>
Subject: RE: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Fri, 27 Aug 2010 03:02:54 +0300
Message-ID: <7E95F01E94AB484F83061FCFA35B39F89BE276@exil.voltaire.com>
References: <adapqx5rtez.fsf@cisco.com><alpine.DEB.2.00.1008261613160.24174@router.home><alpine.DEB.2.00.1008261629440.24174@router.home><20100826.151553.242147157.davem@davemloft.net><20100826222146.GA23025@obsidianresearch.com><alpine.DEB.2.00.1008261825490.26351@router.home> <20100826234342.GA24333@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Or Gerlitz" <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Jason Gunthorpe" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	"Christoph Lameter" <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100826234342.GA24333-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 
> Were you going to try it this way?
> 
>      /* First byte of dgid signals multicast/broadcast when 0xff */
>      if ((wc->wc_flags & IB_WC_GRH) &&
>          ((struct ib_grh *)skb->data)->dgid.raw[0] == 0xff) {
> 	     if (memcmp(((struct ib_grh *)skb->data)->dgid.raw,
>                         dev->broadcast + 4, sizeof(union ib_gid)) ==
0)
>                      skb->pkt_type = PACKET_BROADCAST;
>              else
>                      skb->pkt_type = PACKET_MULTICAST;
>      }
>      else
>              skb->pkt_type = PACKET_HOST;
> 
> I think doing the memcmp only in the multicast path should be
> reasonable overhead wise.
> 

Shouldn't struct ib_grh be packed to make this really work?
The code looks a little messy to me anyway... 
How about using a local var which is a ptr to packed struct ib_grh? The
compiler will probably eliminate it anyway.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
