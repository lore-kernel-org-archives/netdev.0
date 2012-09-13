From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 9/9] drivers/isdn/gigaset/common.c: Remove useless kfree
Date: Thu, 13 Sep 2012 12:19:59 +0300
Message-ID: <20120913091959.GK19396@mwanda>
References: <1347462407-13499-9-git-send-email-peter.senna@gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6FEE@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Senna Tschudin <peter.senna@gmail.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	kernel-janitors@vger.kernel.org, Tilman Schmidt <tilman@imap.cc>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FEE@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 13, 2012 at 09:31:45AM +0100, David Laight wrote:
> > Remove useless kfree() and clean up code related to the removal.
> ...
> > diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
> > index aa41485..30a6b17 100644
> > --- a/drivers/isdn/gigaset/common.c
> > +++ b/drivers/isdn/gigaset/common.c
> > @@ -1123,7 +1123,6 @@ struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
> >  	return drv;
> > 
> >  error:
> > -	kfree(drv->cs);
> >  	kfree(drv);
> >  	return NULL;
> >  }
> > 
> 
> Seems to me that (assuming kfree(NULL) is ok) the kfree()
> is best left in - just in case some other error path is
> added after drv->cs is assigned.
> Better safe than a memory leak.

No.  Delete vestigial code.  There are all kinds of no-ops we could
add to the unwind bits of code if we wanted to so why is "drv->cs"
better than anything else.

First of all, no one is going to change the ISDN code to add an
allocation, but if they did then they have to make sure they don't
leak memory.  That's how it always works.  They can't just assume
that there is going to be a forgotten kfree() hanging off to the
side which is going to take care of it.

regards,
dan carpenter
