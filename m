From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] bluetooth: debugfs changes use too much stack
Date: Sat, 6 Mar 2010 18:30:30 +0300
Message-ID: <20100306153030.GU4958@bicker>
References: <20100306111552.GK4958@bicker> <4B92695F.60601@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Roger Quadros <ext-roger.quadros-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jan Ceuleers <jan.ceuleers-bdq14YP6qtRg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B92695F.60601-bdq14YP6qtRg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 06, 2010 at 03:40:31PM +0100, Jan Ceuleers wrote:
> Dan Carpenter wrote:
> 
> Error handling?
> 
> > The original code would break with a 4K stack.
> > 
> > Signed-off-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> > This was compile tested only.  Sorry about that.
> > 
> > diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
> > index 1a79a6c..835758f 100644
> > --- a/net/bluetooth/hci_sysfs.c
> > +++ b/net/bluetooth/hci_sysfs.c
> > @@ -417,9 +417,11 @@ static ssize_t inquiry_cache_read(struct file *file, char __user *userbuf,
> >  	struct hci_dev *hdev = file->private_data;
> >  	struct inquiry_cache *cache = &hdev->inq_cache;
> >  	struct inquiry_entry *e;
> > -	char buf[4096];
> > +	char *buf;
> >  	int n = 0;
> > +	ssize_t ret;
> >  
> > +	buf = kmalloc(4096, GFP_KERNEL);
> 
> Could this kmalloc not fail?

Grr...  I'm really sorry about that.

I will send an updated patch tomorrow.

regards,
dan carpenter
