From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: Tue, 17 Jun 2003 09:36:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.093624.35663874.davem@redhat.com>
References: <OF606435F1.792217CD-ON86256D48.00563525-86256D48.005A5AE4@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <OF606435F1.792217CD-ON86256D48.00563525-86256D48.005A5AE4@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Tom Lendacky" <toml@us.ibm.com>
   Date: Tue, 17 Jun 2003 11:26:55 -0500
   
   In prep for coding this up I deleted the "x->u.rt.fl = *fl;" line
   and then I noticed that (at least in my configuration) that the
   rt6->rt6i_src address and prefix length in the xfrm_dst structure
   are always zero.

Well, of course.  There is nothing initializing this.

You have to replace the x->u.rt.fl = *fl line with
assignments further down to rt6i_src and friends.
Something like:

	x->u.rt6.rt6i_src = rt0->rt6i_src;

etc. etc.

I don't understand where you expected these assignments
to be made.  This is where the objects get constructed, so
if it isn't being set here, it is being set nowhere :-)
