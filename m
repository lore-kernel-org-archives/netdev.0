From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] net: reorganize sk_buff for faster
 __copy_skb_header()
Date: Fri, 26 Sep 2014 10:35:32 +0200
Message-ID: <20140926103532.52420a79@redhat.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140925164333.7cba128a@redhat.com>
	<1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966AbaIZIfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 04:35:41 -0400
In-Reply-To: <1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2014 14:20:04 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> With proliferation of bit fields in sk_buff, __copy_skb_header() became
> quite expensive, showing as the most expensive function in a GSO
> workload.
> 
> __copy_skb_header() performance is also critical for non GSO TCP
> operations, as it is used from skb_clone()
> 
> This patch carefully moves all the fields that were not copied in a
> separate zone : cloned, nohdr, fclone, peeked, head_frag, xmit_more
> 
> Then I moved all other fields and all other copied fields in a section
> delimited by headers_start[0]/headers_end[0] section so that we
> can use a single memcpy() call, inlined by compiler using long
> word load/stores.
> 
> I also tried to make all copies in the natural orders of sk_buff,
> to help hardware prefetching.
> 
> I made sure sk_buff size did not change.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

I'm impressed, network ninja!

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

It would have been nice if you would have included the performance
improvement you saw, e.g. from:
 http://thread.gmane.org/gmane.linux.network/332035/focus=332086

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
