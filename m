From: "David S. Miller" <davem@redhat.com>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Wed, 11 Feb 2004 20:16:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211201656.4e4f708e.davem@redhat.com>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
	<20040209140853.69ab8bea.davem@redhat.com>
	<Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
	<20040209151053.1f63937a.davem@redhat.com>
	<Pine.LNX.4.58.0402100251380.1251@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402100251380.1251@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2004 03:00:24 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	If you like it in this way you can apply now or after
> some days or to delay it if we want to combine it with other
> device flags or changes.

I like the patch, but I want the documentation changed.

If you'll recall, one of the big problems Alexey and myself
had with the new ARP saddr selection behavior you propose is
that it assumes that: if we do not know of a certain subnet
being on a link than this subnet does not exist there.

In some environments this assumption holds.  But "some != all"
as I often say to a friend of mine :-)

No router has this knowledge completely, and in many environments
such an assumption does not hold.

I know you understand this, which is why your patch keeps the
current behavior the default.

But I want the docs for the sysctl to talk about this.  Something
simple like:

+	1 - Try to avoid local addresses that are not in the target's
+	subnet for this interface as far as we know.  In some environments
+	subnets may be active that this system is not aware of, thus this
+	setting might cause problems in such cases.

Tweak it however you wish, just get the idea/warning across.

I'd also prefer if you at least lightly define what "best" source address
means in the context of arp_announce==2.

Thanks.
