From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number next.
Date: Mon, 11 Apr 2005 15:32:39 +0200
Message-ID: <20050411133239.GM26731@postel.suug.ch>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261699AbVDKNc2@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050411125932.GA19538@uganda.factory.vocord.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Evgeniy Polyakov <20050411125932.GA19538@uganda.factory.vocord.ru> 2005-04-11 16:59
> +	size = NLMSG_SPACE(sizeof(*msg) + msg->len);
> +
> +	skb = alloc_skb(size, gfp_mask);
> +	if (!skb) {
> +		printk(KERN_ERR "Failed to allocate new skb with size=%u.\n", size);
> +		return -ENOMEM;
> +	}
> +
> +	nlh = NLMSG_PUT(skb, 0, msg->seq, NLMSG_DONE, size - sizeof(*nlh));

Needs same fix.

> +	size0 = sizeof(*msg) + sizeof(*ctl) + 3*sizeof(*req);
> +	
> +	size = NLMSG_SPACE(size0);
> +
> +	skb = alloc_skb(size, GFP_ATOMIC);
> +	if (!skb) {
> +		printk(KERN_ERR "Failed to allocate new skb with size=%u.\n", size);
> +
> +		return -ENOMEM;
> +	}
> +
> +	nlh = NLMSG_PUT(skb, 0, 0x123, NLMSG_DONE, size - NLMSG_ALIGN(sizeof(*nlh)));

Just pass size0 instead of reverting the calculation.
