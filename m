From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFT] remove skb_linearize from igmp.c
Date: Mon, 23 Jun 2003 12:02:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030623.120229.59679308.davem@redhat.com>
References: <20030623120342.470cf504.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030623120342.470cf504.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 23 Jun 2003 12:03:42 -0700

   Could someone who actually receives IGMP packets test this?
   
Don't bother, your patch is buggy.

    	int len = skb->len;
 ...
   +	if (!pskb_may_pull(skb, sizeof(struct igmphdr)))
   +		goto drop;
   +	
   +	ih = skb->h.igmph;
   +	if (ip_compute_csum((void *)ih, len)) 
   +		goto drop;

You're only verifying that "sizeof(struct igmphdr)" is available at
skb->data, then you dereference "len" bytes via the call to
ip_compute_csum().
