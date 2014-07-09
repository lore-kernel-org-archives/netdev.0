From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH] netlink: Fix netlink_recvmsg() handling of error from
 netlink_dump().
Date: Wed, 9 Jul 2014 10:32:54 -0700
Message-ID: <20140709173254.GD4291@nicira.com>
References: <1404167704-22408-1-git-send-email-blp@nicira.com>
 <20140707.193735.766947638929765410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:50186 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754252AbaGIRdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 13:33:00 -0400
Received: by mail-vc0-f175.google.com with SMTP id hy4so7568741vcb.6
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 10:33:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140707.193735.766947638929765410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 07, 2014 at 07:37:35PM -0700, David Miller wrote:
> From: Ben Pfaff <blp@nicira.com>
> Date: Mon, 30 Jun 2014 15:35:04 -0700
> 
> > netlink_dump() returns a negative errno value on error.  Until now,
> > netlink_recvmsg() directly recorded that negative value in sk->sk_err,
> > but that's wrong since sk_err takes positive errno values.  (This manifests
> > as userspace receiving a positive return value from the recv() system call,
> > falsely indicating success.)
> > 
> > This bug was introduced in the commit that started checking the
> > netlink_dump() return value, commit b44d211 (netlink: handle errors from
> > netlink_dump()).
> > 
> > Multithreaded Netlink dumps are one way to trigger this behavior in
> > practice, as described in the commit message for the userspace workaround
> > posted here:
> >     http://openvswitch.org/pipermail/dev/2014-June/042339.html
> > 
> > Signed-off-by: Ben Pfaff <blp@nicira.com>
> 
> There's another place, later in this file, doing the same exact thing.
> 
> Please respin this patch, fixing that location too.

Thanks for pointing that out, I sent out v2.
