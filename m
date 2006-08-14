From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Mon, 14 Aug 2006 15:07:08 -0700
Message-ID: <OF76CDD1A8.A722B591-ON882571CA.00781509-882571CA.007980C0@us.ibm.com>
References: <20060813.204405.28205494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kuznet@ms2.inr.ac.ru, michal.ruzicka@comstar.cz,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:47065 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965002AbWHNWH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 18:07:58 -0400
In-Reply-To: <20060813.204405.28205494.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote on 08/13/2006 08:44:05 PM:

> From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
> Date: Fri, 11 Aug 2006 12:04:53 +0100
> 
> > You are absolutely right, I just failed to notice that -ENODEV return 
value
> > from ip_mc_del_src()/ip_mc_leave_src() is ignored.
> > Here comes the patch:
>  ...
> > >         Also, ip_mc_leave_group() has the same issue; looks
> > > like it just needs the "if (in_dev)" removed before the call to
> > > ip_mc_leave_src().
> > 
> > In fact it is a slightly different issue, there is no leak in this
> > function. Rather the function completely fails to leave a multicast
> > group joined on an interface that does not exist any more.
>  ...
> > Here comes a patch for that:
> 
> Both of these fixes look fine to me.  David?

        The first patch in that, yes.

Acked-by: David L Stevens <dlstevens@us.ibm.com>

        I'm not sure the second one is quite right. The case of concern
is where an interface is deleted. If you joined (or left) the group by
address and then deleted the interface, then you wouldn't match the
index (which wouldn't be set) so the leave wouldn't work, still.
        Also, if you passed a completely bogus ifindex, it should return
ENODEV, but with the patch it would return EADDRNOTAVAIL it appears.
        So, I think the second patch needs some more work. I'll look at
it some more and see if I can suggest something better.


                                                        +-DLS

