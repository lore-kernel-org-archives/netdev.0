From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: hw checksum acceleration (Was: problem in driver network code)
Date: Thu, 13 Nov 2003 22:48:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031113224831.A1052@sygehus.dk>
References: <20031107181508.A1102@sygehus.dk> <20031110081417.55732.qmail@web25201.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: francois donzet <fdonzet@yahoo.fr>
Content-Disposition: inline
In-Reply-To: <20031110081417.55732.qmail@web25201.mail.ukl.yahoo.com>; from fdonzet@yahoo.fr on Mon, Nov 10, 2003 at 09:14:17AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 10, 2003 at 09:14:17AM +0100, francois donzet wrote:

> > What do you do with an IEEE 802.1q (VLAN) or 802.2
> > (LLC) packet? The VLAN
> > code in vlan_skb_recv() does not adjust skb->csum or
> > skb->ip_summed. Neither
> > does the 802.2 code.
> 
> no matter the link layer header is 802.3,802.2 or
> 8021.q . Tcp checksum offloading is supported,
> whatever the type of the link layer (as skb->csum is
> computed without the link layer header).

The documentation says that skb->csum covers the whole packet as seen by
netif_rx(). eth_type_trans() pulls off the 14 byte header before netif_rx()
is called. But if the frame is really 802.1q or 802.2, then the extra bytes
of the header will be pulled off but skb->csum will still cover those bytes.
Unless, of course, the device knows about 802.1q and 802.2, but that wasn't
supposed to be necessary, was it?

-- 
Regards,
Rask Ingemann Lambertsen
