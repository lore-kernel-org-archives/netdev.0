From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fix fallout from tg3_readphy() value is zero on error
Date: Tue, 15 Feb 2005 11:11:31 -0800
Message-ID: <20050215111131.29cf288b.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3DA3@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3DA3@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 10:18:14 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> > @@ -793,9 +799,11 @@
> >  
> >  	tg3_writephy(tp, MII_TG3_CTRL, phy9_orig);
> >  
> > -	tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32);
> > -	reg32 &= ~0x3000;
> > -	tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
> > +	if (tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32)) {
> > +		reg32 &= ~0x3000;
> > +		tg3_writephy(tp, MII_TG3_EXT_CTRL, reg32);
> > +	} else if (!err)
> > +		err = -EBUSY;
> >  
> >  	return err;
> >  }
> 
> Shouldn't this be:
> 
> > +	if (!tg3_readphy(tp, MII_TG3_EXT_CTRL, &reg32)) {

Right, fixed in my local tree.

Thanks a lot.
