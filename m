From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: resend [PATCH 2.6.4-rc2] netdevice.h add netif_msg_init helper
Date: Fri, 5 Mar 2004 12:30:42 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403052030.i25KUgF02260@DYN318364BLD.beaverton.ibm.com>
References: <4048D415.4060701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com (Jeff Garzik)
In-Reply-To: <4048D415.4060701@pobox.com> from "Jeff Garzik" at Mar 05, 2004 02:25:09 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With the value 32, all bits would be set not none.  0 -1 sets all the
bits.  Is that not the correct operation?

> > This patch adds a helper function to initialize the debug bit mask
> > for use with netif_msg_*.  When the debug_value is out of range
> > it returns the default_msg_enable_bits.
> > 
> > --- linux-2.6.4-rc2/include/linux/orig.netdevice.h	Thu Mar  4 09:59:08 2004
> > +++ linux-2.6.4-rc2/include/linux/netdevice.h	Thu Mar  4 10:56:19 2004
> > @@ -774,6 +774,17 @@
> >  #define netif_msg_hw(p)		((p)->msg_enable & NETIF_MSG_HW)
> >  #define netif_msg_wol(p)	((p)->msg_enable & NETIF_MSG_WOL)
> >  
> > +static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
> > +{
> > +	/* use default */
> > +	if (debug_value < 0 || debug_value > (sizeof(u32) * 8))
> > +		return default_msg_enable_bits;
> > +	if (debug_value == 0)	/* no output */
> > +		return 0;
> > +	/* set low N bits */
> > +	return(((debug_value == (sizeof(u32)*8)) ? 0 : (1 << debug_value)) - 1);
> > +}
> > +
> 
> Oh, my apologies.  I didn't see you had made the additional change I 
> requested.
> 
> This version looks better, but we still have an out of range value (32) 
> resulting in no-messages, rather than the default value.  I would change 
> the first ">" to ">=", and simply eliminate the final test.
> 
> 	Jeff
> 


-- 
Don Fry
brazilnut@us.ibm.com
