From: "David S. Miller" <davem@redhat.com>
Subject: Re: Casting (struct rtable*) to (struct dst_entry*)
Date: Wed, 19 Mar 2003 21:33:52 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030319.213352.50358237.davem@redhat.com>
References: <200303192355.02509.nalkunda@cse.msu.edu>
	<20030319.205912.131928327.davem@redhat.com>
	<200303200027.41923.nalkunda@cse.msu.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: nalkunda@cse.msu.edu
In-Reply-To: <200303200027.41923.nalkunda@cse.msu.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: N N Ashok <nalkunda@cse.msu.edu>
   Date: Thu, 20 Mar 2003 00:27:41 -0500

   I did see that. But however, I could not understand how "struct rtable" can be 
   casted to "struct dst_entry" and then back again, all the while accessing 
   fields of both structures.

You miss the point that they are the same structure.  It is allocated
the size of "struct rtable" but it may be casted back and forth
between rtable and dst_entry as desired.

void foo(void)
{
	struct rtable rt;
	struct dst_entry *dst;

	rt->u.dst.bar = 1;

	dst = (struct dst_entry *) &rt;
	ASSERT(dst->bar == 1);

	dst = &rt->u.dst;
	ASSERT(dst->bar == 1);
}
