From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Tue, 24 Aug 2004 15:28:07 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>
References: <412A8FB5.4080700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@redhat.com>, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <412A8FB5.4080700@trash.net>
To: Patrick McHardy <kaber@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Then it appears that simply dropping the packet when the
skb->dst == 0 isn't quite right, since per-frag option processing
wouldn't be done in the case where conntrack is removed, but
the first frag does have skb->dst set  (but not some of the others).

In that case, it appears that conntrack needs to flush the entire
frag queue when it's unloaded. That shouldn't happen much,
so maybe that's not such a bad idea.

                                        +-DLS
