From: "David S. Miller" <davem@redhat.com>
Subject: Re: [bernie@develer.com: Kernel 2.6 size increase]
Date: Wed, 23 Jul 2003 12:09:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723120901.57746fd8.davem@redhat.com>
References: <20030723195355.A27597@infradead.org>
	<20030723195504.A27656@infradead.org>
	<20030723115858.75068294.davem@redhat.com>
	<20030723200658.A27856@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20030723200658.A27856@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 20:06:58 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> I know you absolutely disliked Andi's patch to make the xfrm subsystem
> optional so we might need find other ways to make the code smaller
> on those systems that need it.

I'm willing to reconsider it.

So basically we'd have a CONFIG_NET_XFRM, and things like
AH/ESP/IPCOMP/AH6/ESP6/IPCOMP6 would say "select NET_XFRM"
in the Kconfig where they are selected.

Then when CONFIG_NET_XFRM is not set all the xfrm interfaces
called from non-ipsec non-xfrm source files get NOP versions.

Is this exactly what Andi's patch did?  Just send it on
so we can integrate this.

We actually lost a lot of code in other areas of the networking, for
example Andrew Morton and I made many bogus function inlines
undone because they made the code too large.
