From: "David S. Miller" <davem@redhat.com>
Subject: Re: Problem with dev_kfree_skb_any() in 2.6.0
Date: Mon, 29 Mar 2004 16:46:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <047401c415a4$f8bf1a30$d100000a@sbs2003.local>
References: <1072567054.4112.14.camel@gaston><20031227170755.4990419b.davem@redhat.com><3FF0FA6A.8000904@pobox.com><20031229205157.4c631f28.davem@redhat.com><20031230051519.GA6916@gtf.org><20031229220122.30078657.davem@redhat.com><3FF11745.4060705@pobox.com><20031229221345.31c8c763.davem@redhat.com><3FF1B939.1090108@pobox.com><20040101124218.258e8b73.davem@redhat.com><20040102025807.GB3851@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <benh@kernel.crashing.org>, <linux-kernel@vger.kernel.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: <Administrator@oss.sgi.com>
In-Reply-To: <20040102025807.GB3851@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 1 Jan 2004 21:58:07 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> On Thu, Jan 01, 2004 at 12:42:18PM -0800, David S. Miller wrote:
> > Though, is there any particular reason you don't like adding a
> > "|| irqs_disabled()" check to the if statement instead?
> > I prefer that solution better actually.
> 
> Yep, in fact when I wrote the above message, I came across a couple when I
> was pondering...
> * the destructor runs in a more predictable context.
> * given the problem that started this thread, the 'if' test is a
>   potentially problematic area.  Why not eliminate all possibility that
>   this problem will occur again?

The way I see this, dev_kfree_skb_any() is not used in any performance critical
path, so at worst during device shutdown, reset, or power-down, TX queue
packet freeing work could be delayed by up to one jiffie.

Therefore I've put the "|| irqs_disabled()" version of the fix into my tree.

Thanks for working this out with me Jeff :)
