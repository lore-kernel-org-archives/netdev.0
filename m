From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix ip6_build_xmit bug
Date: Sun, 23 Mar 2003 01:22:29 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030323.012229.36386243.davem@redhat.com>
References: <3E7BAC7E.AEC59251@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgrimm2@us.ibm.com
In-Reply-To: <3E7BAC7E.AEC59251@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jon Grimm <jgrimm2@us.ibm.com>
   Date: Fri, 21 Mar 2003 18:21:18 -0600

   Looks like ip6_build_xmit does not allocate room for the
   dev->hard_header_len on the non-fragmentation path as is done in other
   places.  The hard header len gets reserved even though room was not
   allocated for it.  Consequenetly, the put of the raw data can overflow
   the skb. 
   
   Patch below for your consideration.

Applied, but with a minor fix.  We now have a LL_RESERVED_SPACE(dev)
macro in include/linux/netdevice.h that gets this formula correct
and thus I have used it.

Thanks.

And yes we do know things are still slightly broken with ipv6
fragmentation wrt. IPSEC, and that is being actively worked on.
The IPV4 output path hacks just need to be duplicated into ipv6
before that will start working reliably.
