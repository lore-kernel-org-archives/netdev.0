From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] CONNECTOR: add a proc entry to list connectors
Date: Tue, 24 Jun 2008 10:49:53 +0400
Message-ID: <20080624064953.GA1736@2ka.mipt.ru>
References: <48604E44.5040402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38605 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756541AbYFXGtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 02:49:53 -0400
Content-Disposition: inline
In-Reply-To: <48604E44.5040402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Jun 24, 2008 at 09:30:44AM +0800, Li Zefan (lizf@cn.fujitsu.com) wrote:
> I got a problem when I wanted to check if the kernel supports process
> event connector, and It seems there's no way to do this check.
> 
> At best I can check if the kernel supports connector or not, by looking
> into /proc/net/netlink, or maybe checking the return value of bind() to
> see if it's ENOENT.
> 
> So how about add /proc/net/connector to list all supported connectors?
>  # cat /proc/net/connector
>  Name      ID
>  connector 4294967295:4294967295
>  cn_proc   1:1
>  w1        3:1

I like the idea, but if it is not appropriate way, I can extend
connector core itself so it will support not only add/remove
notification of added/removed users, but will also allow to query if
given user exists.

> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Ack.

> +static int cn_proc_show(struct seq_file *m, void *v)
> +{
> +	struct cn_queue_dev *dev = cdev.cbdev;
> +	struct cn_callback_entry *cbq;
> +	unsigned long flags;
> +
> +	seq_printf(m, "Name      ID\n");
> +
> +	spin_lock_irqsave(&dev->queue_lock, flags);

It can be BH lock only.

-- 
	Evgeniy Polyakov
