From: "Or Gerlitz" <or.gerlitz@gmail.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Wed, 27 Sep 2006 22:12:03 +0200
Message-ID: <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben>
	 <Pine.LNX.4.64.0609261317460.24189@zuben>
	 <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Or Gerlitz" <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:17800 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030748AbWI0UME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:12:04 -0400
Received: by py-out-1112.google.com with SMTP id n25so420888pyg
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2006 13:12:04 -0700 (PDT)
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/27/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:
>
> >+      /* XXX set the bond dev type and addr len such that the net core code
> >+      * (eg arp_mc_map() in net/ipv4/arp.c) would correctly process multicast
> >+      * groups set ***before*** the first enslaveness
> >+      */
> >+      bond_dev->type     = bonding_dev_type;
> >+      bond_dev->addr_len = bonding_dev_addrlen;
>
>         I've been thinking about this a little bit more.  The system is
> understandably not set up to deal with this situation, since normal
> devices won't ever change their hardware type.
>
>         You almost want to have some kind of call to induce a reload
> from scratch of the multicast filter settings (along with whatever else
> might be necessary to alter the hardware type on the fly), to be called
> by bonding at the time the first slave is added (since slave adds happen
> in user context, and can therefore hold rtnl as required by most of the
> multicast address handling code).  That seems less hassle than having to
> specify the hardware type and address length at module load time.

I agree that it would be better to avoid doing it this way.
>
>         A side effect of this is that bonds would have to be restricted
> to consisting only of slaves of one hardware type, since slave changes
> (and thus hardware type changes) aren't necessarily restricted to user
> context.

I have addressed the point of putting slaves of different types (and
specifically slave of type ARPHRD_INFINIBAND with slave of other type
in the same bond) in the thead that goes with patch 1/3, let close it
there...

>         Other random thoughts on how to resolve this include modifying
> bonding to accept slaves when the master is down (which would also
> require changes to the initscripts that normally configure bonding), so
> that the initial setting of the, e.g., 224.0.0.1 multicast hardware
> address happens to the already-changed hardware type.

OK, this is a direction i would like to check. Can be nice if you
provide me with a 1-2 liner of directions on what need to be changed
to enable bonding to accept slaves when it down.

Or.
