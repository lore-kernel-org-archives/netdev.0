From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Thu, 19 Aug 2004 08:14:28 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040819081428.5243e314.davem@redhat.com>
References: <20040818091352.GB6507@suse.de>
	<20040819101159.GC3921@sunbeam.de.gnumonks.org>
	<20040819071846.2d0d6120.davem@redhat.com>
	<4124BF7E.7090304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, okir@suse.de, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4124BF7E.7090304@trash.net>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 16:55:58 +0200
Patrick McHardy <kaber@trash.net> wrote:

> These are Olaf's patches. I agree with Harald that the second
> patch is better. I've fixed it up so it applies with the recent
> ip_fragment.c changes.

I have a better idea.

Instead of setting skb->dst to NULL, it should set it to some
NULL destination entry which just frees up the packets.  Then
no special case handling.  skb->dst==NULL packets should never
get into the fragment queue to begin with.
