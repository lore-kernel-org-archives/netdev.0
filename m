From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] [1/2] kernel error reporting (revised)
Date: Tue, 15 Jul 2003 12:51:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715125121.315920a2.akpm@osdl.org>
References: <Mutt.LNX.4.44.0307131052420.2146-100000@excalibur.intercode.com.au>
	<3F143D0A.A052F0B6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, davem@redhat.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk,
   rddunlap@osdl.org, kuznet@ms2.inr.ac.ru, jkenisto@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jim Keniston <jkenisto@us.ibm.com>
In-Reply-To: <3F143D0A.A052F0B6@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jim Keniston <jkenisto@us.ibm.com> wrote:
>
> +int kernel_error_event_iov(const struct iovec *iov, unsigned int nseg,
> +	u32 groups)
> +{
> ...
> +
> +	return netlink_broadcast(kerror_nl, skb, 0, ~0, GFP_ATOMIC);

This appears to be deadlocky when called from interrupt handlers.

netlink_broadcast() does read_lock(&nl_table_lock).  But nl_table_lock is
not an irq-safe lock.

Possibly netlink_broadcast() can be made callable from hardirq context, but
it looks to be non trivial.  The various error and delivery handlers need
to be reviewed, the kfree_skb() calls should be thought about, etc.
