From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPsec support
Date: Tue, 18 Feb 2003 23:02:11 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030218.230211.89243941.davem@redhat.com>
References: <20030219134850.5f203ea7.Kazunori.Miyazawa@jp.yokogawa.com>
	<87znos3j8s.wl@ipinfusion.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Kazunori.Miyazawa@jp.yokogawa.com, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: kunihiro@ipinfusion.com
In-Reply-To: <87znos3j8s.wl@ipinfusion.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kunihiro Ishiguro <kunihiro@ipinfusion.com>
   Date: Tue, 18 Feb 2003 21:57:39 -0800

   I think no need of broadcasting my comments to kernel ML, so I took it
   of from CC:.  netdev guys will be interested in right?  So I kept it.
   
Yes, this is fine.

   1. Do we really need to remove AH header from skb?
   
   In case of IPv4 we modify iph->protocol for further processing thus AH
   header is removed.  But in case of IPv6, we just simply authenticate
   the packet then process next header.  So do we really need to remove
   AH header in IPv6?  Remaining AH header does not harm...
   
This is an interesting topic.

Actually, there is no reason to prefer one way or another.
Remember, if anyone else is interested in SKB contents (such as
tcpdump), that entity has clone of skb and can still see full
contents.

   2. Easy kmalloc()...
   
   It seems there are some easy kmalloc().  Yes I'm stingy with memory.

It is another fun topic.

These are great long term improvements.  But for now, please consider
something important when evaluating "overhead".  This is the fact that
we are performing full encryption or hash function.  Such operation is
quite massively more expensive than kmalloc here and there.

Some day we will have hw acceleration support both at IPSEC and at
crypto library level.  At that time cost analysis will change.

   Well, I'll find more.  Maybe we should be offline and come up with a
   single patch.

I would ask that Alexey and myself stay on the CC: list.

It would not hurt to keep netdev as well, perhaps we can
breed some new experts in our ipsec code :-)
