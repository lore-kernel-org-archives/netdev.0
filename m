From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 13:32:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008133248.1583ddcf.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F8455BE.8080300@sgi.com>
	<20031008183742.GA24822@wotan.suse.de>
	<20031008122223.1ba5ac79.davem@redhat.com>
	<20031008202248.GA15611@oldwotan.suse.de>
	<20031008132402.64984528.davem@redhat.com>
	<20031008203306.GB15611@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, modica@sgi.com, johnip@sgi.com, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031008203306.GB15611@oldwotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 22:33:06 +0200
Andi Kleen <ak@suse.de> wrote:

> Well, this thread was about the tigon3 and I don't see that as an el cheapo
> card. If SGI uses it on the Altix I guess they want it to perform well 
> with many CPUs.

It's one of the oldest variants of the tg3 chip and it's full
of hardware bugs when used in PCI-X.

> I personally think it's better to just use slab to implement it,
> allocating pages doesn't seem to have any advantages to me.

The page chunk allocator is meant to make it easier to put the
non-header parts in the frag list of the SKB, see?  It means we
don't need to do anything special in the networking, all the
receive paths handle frag'd RX packets properly.

We can't take pages SLAB is using and attach them to the fraglist
of the SKB, kfree_skb() is going to try and put_page() on them.

If we used slab, we'd need to do something like:

1) skb->h.raw or whatever have special meaning and point to
   different buffers.

2) There's a skb->data2 or something like that.

Both are a lot of work compared to my suggestion.
