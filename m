From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch linux-2.6.11-bk10 1/1] r8169: incoming frame length check
Date: Wed, 16 Mar 2005 22:09:49 +0100
Message-ID: <20050316210949.GA27477@electric-eye.fr.zoreil.com>
References: <20050314233103.GC16072@electric-eye.fr.zoreil.com> <200503161430.17943.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com,
        Stephen Hemminger <shemminger@osdl.org>, mark@kiora.ath.cx
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200503161430.17943.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> > - /* For gigabit rtl8169, MTU + header + CRC + VLAN */
> > - RTL_W16(RxMaxSize, tp->rx_buf_sz);
> > + /* Low hurts. Let's disable the filtering. */
> > + RTL_W16(RxMaxSize, 16383);
> 
> Wouldn't a #define be better than 16k-1?  Perhaps, RxPacketMaxSize could be 
> used.

RxPacketMaxSize does not tell a lot more. It is (imho) still a bit too neutral
as something badly sucks when you try to filter the packet size.

I'll welcome suggestions for something which summarizes "The maximal jumbo
frame size as it is actually needed to disable the filtering".

On a different topic: Mark and I tested the patch as well. Even if it is not
exactly trivial, it could make sense to push it for submission on 2.6.11.x.
Without it one do not want to be on a public Gb link (sic).

Executive summary:
- (patch already included in 2.6.11.x): the Rx ring occasionally announced
  wrong size for the Rx DMA buffers;

- (current patch): the packet length indication in a descriptor after
  Rx DMA can be related to a packet which spans several descriptors. So it
  is inaccurate for skb_put.

--
Ueimor
