From: N N Ashok <nalkunda@cse.msu.edu>
Subject: Re: Casting (struct rtable*) to (struct dst_entry*)
Date: Thu, 20 Mar 2003 01:02:38 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303200102.38813.nalkunda@cse.msu.edu>
References: <200303192355.02509.nalkunda@cse.msu.edu> <200303200027.41923.nalkunda@cse.msu.edu> <20030319.213352.50358237.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030319.213352.50358237.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 20 March 2003 00:33, David S. Miller wrote:
>    From: N N Ashok <nalkunda@cse.msu.edu>
>    Date: Thu, 20 Mar 2003 00:27:41 -0500
>
>    I did see that. But however, I could not understand how "struct rtable"
> can be casted to "struct dst_entry" and then back again, all the while
> accessing fields of both structures.
>
> You miss the point that they are the same structure.  It is allocated
> the size of "struct rtable" but it may be casted back and forth
> between rtable and dst_entry as desired.
>
> void foo(void)
> {
> 	struct rtable rt;
> 	struct dst_entry *dst;
>
> 	rt->u.dst.bar = 1;
>
> 	dst = (struct dst_entry *) &rt;
> 	ASSERT(dst->bar == 1);
>
> 	dst = &rt->u.dst;
> 	ASSERT(dst->bar == 1);
> }

I think I finally understand the whole setup. Please correct if I'm wrong.
"struct rtable" has its first field "u" which is a union of "dst_entry" and 
"struct rtable *". Thus when we cast rtable to dst_entry, we are accessing 
the rtable.u.dst_entry itself and not any other part of rtable.
Since originally the data was allocated the size of "rtable", when we cast 
"dst_entry" to "struct rtable" we can access all the fields of "struct 
table".

Thanks a lot for the clarification.

Ashok
