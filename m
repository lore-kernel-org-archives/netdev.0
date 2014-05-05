From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] isdn: hisax: clean up some indenting
Date: Mon, 5 May 2014 10:44:34 +0300
Message-ID: <20140505074434.GN26890@mwanda>
References: <20140503202012.GC32753@mwanda>
 <53668DFC.6040106@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, Jiri Kosina <jkosina@suse.cz>,
	Randy Dunlap <rdunlap@infradead.org>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53668DFC.6040106@bfs.de>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 04, 2014 at 08:59:08PM +0200, walter harms wrote:
> > @@ -1051,12 +1054,13 @@ tx_b_frame(struct hfc4s8s_btype *bch)
> >  			cnt -= 4;
> >  		}
> >  
> > -		while (cnt--)
> > +		while (cnt--) {
> >  #ifdef HISAX_HFC4S8S_PCIMEM
> >  			fWrite_hfc8(l1->hw, A_FIFO_DATA0, *cp++);
> >  #else
> > -		fWrite_hfc8(l1->hw, *cp++);
> > +			fWrite_hfc8(l1->hw, *cp++);
> >  #endif
> > +		}
> 
> This looks wrong. The read above uses Read_hfc8/fRead_hfc8 (easy to
> confuse but i am not the maintainer ....)
> here we have 2* fWrite_hfc8() ?
> Does this compile with HISAX_HFC4S8S_PCIMEM ??
> 

Yeah.  You're right.  The first fWrite_hfc8() should be Write_hfc8().
This same mistake is made two other places which prevents the driver
from compiling with HISAX_HFC4S8S_PCIMEM.

I will just delete this code since it has been broken since 2.6.12.
Let me resend.

regards,
dan carpenter

