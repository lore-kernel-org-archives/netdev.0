From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch] bluetooth: debugfs changes use too much stack
Date: Sat, 06 Mar 2010 09:49:43 -0800
Message-ID: <1267897783.3712.0.camel@localhost.localdomain>
References: <20100306111552.GK4958@bicker> <4B92695F.60601@computer.org>
	 <20100306153030.GU4958@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Young <hidave.darkstar@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Roger Quadros <ext-roger.quadros@nokia.com>,
	Bing Zhao <bzhao@marvell.com>, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57264 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab0CFRvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 12:51:32 -0500
In-Reply-To: <20100306153030.GU4958@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

> > Error handling?
> > 
> > > The original code would break with a 4K stack.
> > > 
> > > Signed-off-by: Dan Carpenter <error27@gmail.com>
> > > ---
> > > This was compile tested only.  Sorry about that.
> > > 
> > > diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
> > > index 1a79a6c..835758f 100644
> > > --- a/net/bluetooth/hci_sysfs.c
> > > +++ b/net/bluetooth/hci_sysfs.c
> > > @@ -417,9 +417,11 @@ static ssize_t inquiry_cache_read(struct file *file, char __user *userbuf,
> > >  	struct hci_dev *hdev = file->private_data;
> > >  	struct inquiry_cache *cache = &hdev->inq_cache;
> > >  	struct inquiry_entry *e;
> > > -	char buf[4096];
> > > +	char *buf;
> > >  	int n = 0;
> > > +	ssize_t ret;
> > >  
> > > +	buf = kmalloc(4096, GFP_KERNEL);
> > 
> > Could this kmalloc not fail?
> 
> Grr...  I'm really sorry about that.
> 
> I will send an updated patch tomorrow.

please don't since we fixed this already in the net-2.6 tree.

Regards

Marcel


