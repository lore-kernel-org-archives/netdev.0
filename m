From: N N Ashok <nalkunda@cse.msu.edu>
Subject: Re: Casting (struct rtable*) to (struct dst_entry*)
Date: Thu, 20 Mar 2003 00:27:41 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200303200027.41923.nalkunda@cse.msu.edu>
References: <200303192355.02509.nalkunda@cse.msu.edu> <20030319.205912.131928327.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030319.205912.131928327.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Wednesday 19 March 2003 23:59, David S. Miller wrote:
>    From: N N Ashok <nalkunda@cse.msu.edu>
>    Date: Wed, 19 Mar 2003 23:55:02 -0500
>
>    I am unable to understand how a rtable structure casted to dst_entry
> will give a correct pointer to the input() function. I looked at the fields
> in rtable and dst_entry, the fields in the structures are cannot be lined
> up (the fourth field in rtable is not the same type as the fourth field in
> dst_entry).
>
> "struct rtable" starts with a "struct dst_entry"

Thanks David.

I did see that. But however, I could not understand how "struct rtable" can be 
casted to "struct dst_entry" and then back again, all the while accessing 
fields of both structures. When the (struct rtable *)rth is filled in 
ip_route_input(), the variables accessed are those of rtable. Then rth is 
cast to (struct dst_entry *) and assigned to skb->dst (which is of type 
struct dst_entry *). 
After this, in ip_rcv_finish(), the field of dst_entry is accessed as in:
skb->dst->input(). I am unable to understand how, data filled in as rtable 
fields will be valid when accessed as dst_entry fields.
Later in ip_forward() (for a packet to be forwarded), the skb->dst is cast to 
(struct rtable *) and its fields accessed.

A correction to the previous post: the skb->dst->input() is invoked in 
ip_rcv_finish() and not in ip_route_input() as mentioned in the post.

Thanks,
Ashok
