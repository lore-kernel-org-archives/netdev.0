From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sat, 26 Feb 2005 12:36:17 -0600
Message-ID: <200502261236.17332.jdmason@us.ibm.com>
References: <42208D83.80803@phekda.gotadsl.co.uk> <200502261132.29261.jdmason@us.ibm.com> <4220B9C6.1010106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>,
        Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4220B9C6.1010106@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 26 February 2005 12:02 pm, Jeff Garzik wrote:
[...]
> > @@ -255,6 +258,9 @@ enum RTL8169_register_content {
> >         Cfg9346_Lock = 0x00,
> >         Cfg9346_Unlock = 0xC0,
> >  
> > +       /* StatsAddr register */
> > +       DumpStats = (1 << 3),
> > +
> > 
> > Wouldn't this be better as "0x08"?  Also, RTL8169_register_content could 
> > do with a bit of tidying (values are expressed in decimal and hex, some 
> > are aligned and others not, etc).  I'll try and come-up with a patch here 
> > in a bit.   
> 
> The form "(1 << n)" is preferred, since that form makes plain the bit 
> number, with zero neural transformation required.
> 
> Use the more readable form.  Cleanup patches accepted.

My suggestion was based on code uniformity (as the rest of the values are 
defined as dex or decimal numbers).  Which takes presidense, uniformity or 
readablity?  If it is the latter, should the rest of thse values be redefined?

> 
> >         /* rx_mode_bits */
> >         AcceptErr = 0x20,
> >         AcceptRunt = 0x10,
> > @@ -380,6 +386,22 @@ struct ring_info {
> >         u8              __pad[sizeof(void *) - sizeof(u32)];
> >  };
> >  
> > +struct rtl8169_stats {
> > +       u64 tx_ok;
> > +       u64 rx_ok;
> > +       u64 tx_err;
> > +       u32 rx_err;
> > +       u16 rx_fifo;
> > +       u16 frame_align;
> > +       u32 tx_ok_1col;
> > +       u32 tx_ok_mcol;
> > +       u64 rx_ok_phys;
> > +       u64 rx_ok_bcast;
> > +       u32 rx_ok_mcast;
> > +       u16 tx_abort;
> > +       u16 tx_underrun;
> > +} __attribute__((packed));
> > +
> > 
> > 
> > These could all be u64's.  It would take-up more memory (and a bit more code in the register dump), but the values would be more accurate.  Just an idea.
> 
> No, this is the representation of the hardware DMA structure.
> 
> It is defined by the hardware, not the programmer.

Sorry, didn't see that on the first pass.  My apologies.
 
Jon
