From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH v1 2/3] net: add VEPA, VEB bridge mode
Date: Tue, 5 Jun 2012 08:41:40 +0530
Message-ID: <OFA7A8AFF8.053F5108-ON65257A14.0010E4B8-65257A14.001182C8@in.ibm.com>
References: <20120530030531.7443.72024.stgit@jf-dev1-dcblab> <20120530030705.7443.22155.stgit@jf-dev1-dcblab> <OF0D72A103.6F322B98-ON65257A13.00500E50-65257A13.005272D6@in.ibm.com> <4FCCE46C.7080809@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bhutchings@solarflare.com, buytenh@wantstofly.org,
	eilong@broadcom.com, eric.w.multanen@intel.com,
	gregory.v.rose@intel.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, mst@redhat.com,
	netdev@vger.kernel.org, shemminger@vyatta.com, sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:50395 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761387Ab2FEDMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 23:12:44 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Tue, 5 Jun 2012 08:42:41 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q553CK9V3080578
	for <netdev@vger.kernel.org>; Tue, 5 Jun 2012 08:42:21 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q558g7uR012150
	for <netdev@vger.kernel.org>; Tue, 5 Jun 2012 18:42:08 +1000
In-Reply-To: <4FCCE46C.7080809@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend <john.r.fastabend@intel.com> wrote on 06/04/2012 10:08:04
PM:

> > I think you should do something like:
> >
> >         if ((flags == BRIDGE_FLAGS_MASTER) && ...)
> >                 ...
> >
> > Also you could use BRIDGE_FLAGS_MASTER=1, SELF=2, and use
> > "if (flags & BRIDGE_FLAGS_MASTER)" for consistency?
>
> OK this is likely a good thing otherwise user space is a
> bit tedious when managing FDB and bridge modes. We do still
> need the !flags case to support existing applications though,
> (we must maintain existing semantics)
>
> if (!flags || (flags & BRIDGE_FLAGS_MASTER) && ...)
>    ...
> else (flags & BRIDGE_FLAGS_SELF)
>    ...

Yes, looks good.

> > It is possible to return a reporting error even though
> > the operation succeeded. Maybe something that could be
> > done here to indicate that the operation succeeded, or
> > is that a TODO?
> >
>
> The problem is if rtnl_bridge_notify fails due to memory
> constraints or otherwise. In this case the set has already
> completed successfully as you note so we should not return
> any error. This should fix it if I understand your concern
> correctly.
>
>    if (!err)
>       rtnl_bridge_notify(dev, flags);
>    return err;

Yes. I guess user will not hang waiting for a response as it
will pass NLM_F_ACK, which allows netlink_rcv_skb to call
netlink_ack.

Thanks,
- KK
