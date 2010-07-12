From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] 9p: strlen() doesn't count the terminator
Date: Mon, 12 Jul 2010 23:51:01 +0200
Message-ID: <20100712215101.GG5658@bicker>
References: <20100710095154.GU19184@bicker> <20100712130458.bb8ae751.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Abhishek Kulkarni <adkulkar@umail.iu.edu>,
	Venkateswararao Jujjuri <jvrao@us.ibm.com>,
	linux-kernel@vger.kernel.org,
	Tilman Sauerbeck <tilman@code-monkey.de>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100712130458.bb8ae751.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 12, 2010 at 01:04:58PM -0700, Andrew Morton wrote:
> > diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
> > index 98ce9bc..c85109d 100644
> > --- a/net/9p/trans_fd.c
> > +++ b/net/9p/trans_fd.c
> > @@ -948,7 +948,7 @@ p9_fd_create_unix(struct p9_client *client, const char *addr, char *args)
> >  
> >  	csocket = NULL;
> >  
> > -	if (strlen(addr) > UNIX_PATH_MAX) {
> > +	if (strlen(addr) >= UNIX_PATH_MAX) {
> >  		P9_EPRINTK(KERN_ERR, "p9_trans_unix: address too long: %s\n",
> >  			addr);
> >  		return -ENAMETOOLONG;
> 
> This bug doesn't strike me as serious enough to warrant backporting the fix
> into -stable.  What was your thinking there?

I don't feel strongly about it.  It's safe enough and it applies
cleanly.  On the other hand, root should always control the name of the
device to mount so it's not a big deal.

regards,
dan carpenter
