From: N N Ashok <nalkunda@cse.msu.edu>
Subject: Casting (struct rtable*) to (struct dst_entry*)
Date: Wed, 19 Mar 2003 23:55:02 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200303192355.02509.nalkunda@cse.msu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
   I have been looking at the networking code of Linux for my Masters thesis. 
I observed the following:
In ip_route_input(), if a route is found in the cache, the skb->dst is setup 
with the route found by casting the rtable entry to dst_entry:
	skb->dst = (struct dst_entry*)rth;

Later in ip_route_input(), skb->dst->input() is called:
	return skb->dst->input(skb);

In ip_forward(), skb->dst is again casted to rtable:
	rt = (struct rtable*)skb->dst;

I am unable to understand how a rtable structure casted to dst_entry will give 
a correct pointer to the input() function. I looked at the fields in rtable 
and dst_entry, the fields in the structures are cannot be lined up (the 
fourth field in rtable is not the same type as the fourth field in 
dst_entry). 

Can anybody help me understand this casting of rtable to dst_entry and then 
back to rtable?

Thanks,
Ashok
