From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: panic on 2.6.11
Date: Sat, 5 Mar 2005 00:58:04 +0100
Message-ID: <20050304235804.GD1148@electric-eye.fr.zoreil.com>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net> <20050304145317.772859da@dxpl.pdx.osdl.net> <20050304230214.GC1148@electric-eye.fr.zoreil.com> <200503041728.54026.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200503041728.54026.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> > @@ -2210,6 +2211,24 @@ rtl8169_rx_interrupt(struct net_device *
> >     pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
> >         tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
> >
> > +   if (pkt_size >= tp->rx_buf_sz) {
> > +    show_size = 1;
> > +    pkt_size = tp->rx_buf_sz;
> > +   }
> 
> Shouldn't the above be dev->mtu (instead of tp->rx_buf_sz), otherwise there 
> won't be enough room for ethernet header, CRC, etc.

There is no room left in the buffer. I want it to be translated into the
biggest skb_put() possible. tp->rx_buf_sz already account the headers (see
rtl8169_set_rxbufsize), no ?

At worst it is possible we are a bit pessimistic imho.

--
Ueimor
