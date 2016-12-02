From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Fri, 2 Dec 2016 20:28:10 +0100
Message-ID: <20161202192810.GA3259@netboy>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-5-grygorii.strashko@ti.com>
 <20161130184511.GB8209@netboy>
 <875d4cc2-8a47-b06d-fb46-0cacc28dbaee@ti.com>
 <20161130221738.GA13099@localhost.localdomain>
 <20161202095848.GA14586@localhost.localdomain>
 <bfbebf2d-d057-6a21-845c-48f0a9ab0404@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <bfbebf2d-d057-6a21-845c-48f0a9ab0404-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 02, 2016 at 11:58:34AM -0600, Grygorii Strashko wrote:
> or I missed smth?

You are missing three important points.

1. Unlike the code you posted, no edges will be lost.

2. The solution using the PWM is implemented in USER SPACE.  If people
   use this way, then they will be forced to understand the inherit
   limitations.  In addition, the behavior of servo will be under
   their control.

3. The update rate of the PHC is not once per second.  It can be any
   rate at all, like 16 Hz for the telecom profile.  You can't just
   blindly pick out an adjustment value once per second.  Using the
   feedback from the time stamped PWM and adjusting THAT at the PWM
   rate (also not necessarily 1 PPS) is the right way.  The second
   reply in that thread is an even better solution, leaving the PHC
   free running and adjusting the timer input clock (probably they
   used a VCO).

Just hacking in some kind of kernel PPS with unknown accuracy is just
asking for trouble later, since people will expect HW accuracy.

So just get the input time stamps working, and make PWM control
available to userspace in mainline (not sure about this, I guess it
isn't), and leave the PPS part to a userspace utility.

Thanks,
Richard



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
