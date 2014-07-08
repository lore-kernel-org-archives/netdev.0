From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v2] xen-netback: Adding debugfs
 "io_ring_qX" files
Date: Tue, 8 Jul 2014 11:01:04 -0400
Message-ID: <20140708150104.GA2863@laptop.dumpdata.com>
References: <1404330830-24504-1-git-send-email-zoltan.kiss@citrix.com>
 <20140702200252.GA17294@laptop.dumpdata.com>
 <53BC014E.5090600@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53BC014E.5090600@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 08, 2014 at 03:33:50PM +0100, Zoltan Kiss wrote:
> On 02/07/14 21:02, Konrad Rzeszutek Wilk wrote:
> >On Wed, Jul 02, 2014 at 08:53:50PM +0100, Zoltan Kiss wrote:
> >>+static ssize_t
> >>+xenvif_write_io_ring(struct file *filp, const char __user *buf, size_t count,
> >>+		     loff_t *ppos)
> >>+{
> >>+	struct xenvif_queue *queue =
> >>+		((struct seq_file *)filp->private_data)->private;
> >>+	int len;
> >>+	char write[sizeof("kick")];
> >
> ><blinks>
> >>+
> >>+	/* don't allow partial writes and check the length */
> >>+	if (*ppos != 0)
> >>+		return 0;
> >>+	if (count < sizeof("kick") - 1)
> >
> >Um, could you just use a #define please?
> OK
> 
> >
> >>+		return -ENOSPC;
> >>+
> >>+	len = simple_write_to_buffer(write,
> >>+				     sizeof(write),
> >>+				     ppos,
> >>+				     buf,
> >>+				     count);
> >>+	if (len < 0)
> >>+		return len;
> >>+
> >>+	if (!strncmp(write, "kick", sizeof("kick") - 1))
> >>+		xenvif_interrupt(0, (void *)queue);
> >>+	else
> >>+		pr_warn("Unknown command to io_ring. Available: kick\n");
> >
> >It is 'io_ring_q%d'?
> Yes
> 
> >Why don't you split that back out to the user
> >instead of the console?
> How do you mean? Printing it into buf? I don't think the user cares about
> its content after doing the write syscall. More importantly, I don't know if
> that buffer is big enough to hold the message.

Isn't it 4K? 

Either way I think you need to do 'count = -EINVAL' here.
