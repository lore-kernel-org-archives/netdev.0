From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: deinline netif_tx_stop_queue() and
 netif_tx_stop_all_queues()
Date: Thu, 07 May 2015 11:44:37 -0700
Message-ID: <1431024277.18597.11.camel@perches.com>
References: <1430998870-1453-1-git-send-email-dvlasenk@redhat.com>
	 <554B9D82.80101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <554B9D82.80101@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-07 at 10:14 -0700, Alexander Duyck wrote:
> On 05/07/2015 04:41 AM, Denys Vlasenko wrote:
> > These functions compile to ~60 bytes of machine code each.
> >
> > With this .config: http://busybox.net/~vda/kernel_config
> > there are 617 calls to netif_tx_stop_queue()
> > and 49 calls to netif_tx_stop_all_queues() in vmlinux.
> >
> > Code size is reduced by 27 kbytes:

[]

> This is the WARN_ON action.  One thing you might try doing is moving 
> this to a function of its own instead of moving the entire thing out of 
> being an inline.  You may find you still get most of the space savings 
> as I wonder if the string for the printk isn't being duplicated for each 
> caller.

It is effectively duplicated (with different prefixes) if there is a
#define pr_fmt(fmt) "some_prefix: " fmt
before this code is reached.  That's most callers now.

The code that doesn't have a pr_fmt should get symbol deduplicated
at link time.
