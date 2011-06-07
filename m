From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] Use unsigned variables for packet lengths in ip[6]_queue.
Date: Tue, 7 Jun 2011 10:39:24 -0400
Message-ID: <20110607143924.GA5257@redhat.com>
References: <20110420014221.GC26949@redhat.com>
 <20110419.204105.68144653.davem@davemloft.net>
 <20110528003651.GA8380@redhat.com>
 <20110602.135742.1323883827030625599.davem@davemloft.net>
 <4DEE209C.2010104@trash.net>
 <4DEE335C.1010504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DEE335C.1010504@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 07, 2011 at 04:19:08PM +0200, Patrick McHardy wrote:
 
 > >>> With the patch below, I haven't been able to reproduce the problem, but
 > >>> I don't know if I've inadvertantly broken some other behaviour somewhere
 > >>> deeper in netlink where this is valid.
 > > 
 > > This is fine, but I'm wondering whether this can really fix the problem
 > > you've been seeing. Before the packet is reallocated, the length of
 > > nlmsglen - NLMSGLEN(0) - sizeof(struct ipq_peer_msg) is compared to
 > > ipq_peer_msg->data_len, so both values need to be wrong.
 > > ipq_peer_msg->data_len is a size_t, so it's unsigned.
 > > 
 > > I think what we should additionally do is verify that data_len < 65535
 > > since that's the maximum size of an IP packet.
 > 
 > We're actually already doing this. This makes it even more strange that
 > you're seeing this problem. Could you send me your testcase?

I don't have a standalone test-case, just a generic fuzzing tool that passes
sockets to various syscalls.  You can clone it from git://git.codemonkey.org.uk/trinity.git/
(the test-random.sh should explain how to use it)

	Dave.

