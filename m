From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] consolidate skb delivery
Date: Tue, 7 Oct 2003 03:40:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007034003.7a926a05.davem@redhat.com>
References: <20031002102133.7285b5ee.shemminger@osdl.org>
	<20031002192546.GA29673@wotan.suse.de>
	<20031002124345.7b34bf24.shemminger@osdl.org>
	<20031003001128.587ac102.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031003001128.587ac102.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 00:11:28 -0700
"David S. Miller" <davem@redhat.com> wrote:

> I would suggest we eliminate support for old style protocols
> now.  We can do that by making the ptype registry in net/core/dev.c
> fail if the thing being registered is old-style.
> 
> I'll code this up.

Ok, as it turns out, instead I converted all the old-style
protocols.  When things seemed really complex or hard to
convert easily I just put:

	nskb = skb_copy(skb, GFP_ATOMIC);
	if (!nskb)
		goto drop;
	kfree_skb(skb);
	skb = nskb;

at the top of the input handler.  The only instance that I did
this for actually was x25.
