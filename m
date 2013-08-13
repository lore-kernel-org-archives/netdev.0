From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/3] net/usb/r8152: support aggregation
Date: Tue, 13 Aug 2013 20:32:26 +0800
Message-ID: <9E410853D1BD483E9479C175D5E72EB6@realtek.com.tw>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com> <1376383742.1681.1.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: 'Oliver Neukum' <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376383742.1681.1.camel@linux-fkkt.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Oliver Neukum [mailto:oneukum@suse.de] 
> Sent: Tuesday, August 13, 2013 4:49 PM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> linux-usb@vger.kernel.org
> Subject: Re: [PATCH net-next 1/3] net/usb/r8152: support aggregation
> 
[...]
> > +               len_used = 0;
> > +               rx_desc = agg->head;
> > +               rx_data = agg->head;
> > +               smp_wmb();
> > +               pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
> > +               len_used += sizeof(struct rx_desc) + pkt_len;
> > +
> > +               while (urb->actual_length >= len_used) {
> > +                       if (pkt_len < ETH_ZLEN)
> > +                               break;
> > +
> > +                       pkt_len -= 4; /* CRC */
> > +                       rx_data += sizeof(struct rx_desc);
> > +
> > +                       skb = netdev_alloc_skb_ip_align(netdev,
> > pkt_len);
> > +                       if (!skb) {
> > +                               stats->rx_dropped++;
> > +                               break;
> > +                       }
> > +                       memcpy(skb->data, rx_data, pkt_len);
> > +                       skb_put(skb, pkt_len);
> > +                       skb->protocol = eth_type_trans(skb, netdev);
> > +                       netif_rx(skb);
> > +                       stats->rx_packets++;
> > +                       stats->rx_bytes += pkt_len;
> > +
> > +                       rx_data = rx_agg_align(rx_data + 
> pkt_len + 4);
> > +                       rx_desc = (struct rx_desc *)rx_data;
> > +                       smp_wmb();
> 
> Against what is the memory barrier?

Excuse me. I don't understand your question. Do you mean the function should not
be used here?

Best Regards,
Hayes
