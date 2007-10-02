From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net/r8169.c - trivial - add KERN_DEBUG to
	dprintk and PFX before KERN_ uses
Date: Tue, 02 Oct 2007 10:06:37 -0700
Message-ID: <1191344797.13170.41.camel@localhost>
References: <1191343038.13170.32.camel@localhost>
	 <47027895.3050208@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3115 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754640AbXJBRU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:20:28 -0400
In-Reply-To: <47027895.3050208@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-02 at 12:57 -0400, Jeff Garzik wrote:
> \> @@ -1924,7 +1925,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
> >  
> >  	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
> >  	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
> > -		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
> > +		dprintk("Set MAC Reg C+CR Offset 0xE0. "
> >  			"Bit-3 and bit-14 MUST be 1\n");
> >  		tp->cp_cmd |= (1 << 14);
> >  	}
> 
> NAK these, the author clearly prefers his debugging output at KERN_INFO 
> level

This fixes an expanded printk(PFX KERN_INFO PFX foo) bug.

That the author "clearly prefers" is dubious.

The rest of the dprintk uses are undefined.

$ grep dprintk drivers/net/r8169.c
        dprintk("mac_version = 0x%02x\n", tp->mac_version);
                        dprintk("phy_version == %s (%04x)\n", p->msg, p->reg);
        dprintk("phy_version == Unknown\n");
        dprintk("MAC version != 0 && PHY version == 0 or 1\n");
        dprintk("Do final_reg2.cfg\n");
        dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
                dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
                dprintk("Set PHY Reg 0x0bh = 0x00h\n");
                dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "

If the author does so prefer KERN_INFO levels, it's better to use:

#define dprintk(fmt, arg...) \
	do { printk(KERN_INFO PFX fmt, ## arg); } while (0)

cheers,  Joe


