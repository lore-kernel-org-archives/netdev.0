From: "Tom Lendacky" <toml@us.ibm.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: Tue, 17 Jun 2003 13:38:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5E3AE43A.9C52FDB9-ON86256D48.0064B1C4-86256D48.0066613A@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


   Well, of course.  There is nothing initializing this.

   You have to replace the x->u.rt.fl = *fl line with
   assignments further down to rt6i_src and friends.
   Something like:

             x->u.rt6.rt6i_src = rt0->rt6i_src;

   etc. etc.

   I don't understand where you expected these assignments
   to be made.  This is where the objects get constructed, so
   if it isn't being set here, it is being set nowhere :-)

Ok, my explanation could have been better.  In __xfrm6_bundle_create,
rt0->rt6i_src address and prefix length are zero (as well as rt->rt6i_src)
and so in __xfrm6_find_bundle the values in the xfrm_dst structure were
then zero.

So doing a tunnel mode ping from fec0::1 to fec0:0:0:2::11 in my
configuration, the following values exist in __xfrm6_bundle_create:

  rt0->rt6i_src.addr = 0000:0000:0000:0000:0000:0000:0000:0000
  rt0->rt6i_src.plen = 0
  rt0->rt6i_dst.addr = fec0:0000:0000:0002:0000:0000:0000:0000
  rt0->rt6i_dst.plen = 64

  rt->rt6i_src.addr  = 0000:0000:0000:0000:0000:0000:0000:0000
  rt->rt6i_src.plen  = 0
  rt->rt6i_dst.addr  = fec0:0000:0000:0000:0000:0000:0000:0002
  rt->rt6i_dst.plen  = 128

Sorry for the confusion.

Thanks,
Tom
