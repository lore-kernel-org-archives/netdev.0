From: "David S. Miller" <davem@redhat.com>
Subject: Re: Problem with dev_kfree_skb_any() in 2.6.0
Date: Thu, 1 Jan 2004 12:42:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040101124218.258e8b73.davem@redhat.com>
References: <1072567054.4112.14.camel@gaston>
	<20031227170755.4990419b.davem@redhat.com>
	<3FF0FA6A.8000904@pobox.com>
	<20031229205157.4c631f28.davem@redhat.com>
	<20031230051519.GA6916@gtf.org>
	<20031229220122.30078657.davem@redhat.com>
	<3FF11745.4060705@pobox.com>
	<20031229221345.31c8c763.davem@redhat.com>
	<3FF1B939.1090108@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FF1B939.1090108@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Dec 2003 12:43:21 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Luckily, I feel there is an easy solution, as shown in the attached 
> patch.  We _already_ queue skbs in dev_kfree_skb_irq().  Therefore, 
> dev_kfree_skb_any() can simply use precisely that same solution.  The 
> raise-softirq code will immediately proceed to action if we are not in 
> hard IRQ context, otherwise it will follow the expected path.

Ok, this is reasonable and works.

Though, is there any particular reason you don't like adding a
"|| irqs_disabled()" check to the if statement instead?
I prefer that solution better actually.
