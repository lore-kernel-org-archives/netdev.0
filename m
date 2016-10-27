From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC net-next iproute2 1/2] libnetlink: Add test for error code
 returned from netlink reply
Date: Thu, 27 Oct 2016 11:24:04 +0300
Message-ID: <20161027082404.GC1867@uranus.lan>
References: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
 <1477510208-20292-2-git-send-email-gorcunov@gmail.com>
 <20161026205256.162e1d25@xeon-e3>
 <20161027065253.GB1867@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36444 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942438AbcJ0OM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:12:27 -0400
Received: by mail-lf0-f66.google.com with SMTP id b75so2030410lfg.3
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:12:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161027065253.GB1867@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 09:52:53AM +0300, Cyrill Gorcunov wrote:
...
> > 
> > This looks like a mistake in how you implemented the functionality in the kernel.
> > Despite what it looks like, all netlink request/reply functionality reports
> > errors in current implementation by returning error to the sendmsg request.
> > 
> > What you added implies that the new kernel api is wrong, or many other usages
> > are wrong.  Please fix the kernel.
> 
> No. This is not my code. This code has been in kernel for the really long time.
> I don't know why you've not been doing such test in libnetlink before.
> 
> Actually I've hit this problem accidentaly -- I made a patch 2 from this
> set and run it on the machine where kernel was unpatched, ie without
> raw-diag module, and I found that we can't figure out if kernel notified
> us that some diag module simply not present in the system. And here is
> the only way to find it out.

Also, drop this series for a while, I'll resend new one: the status of
diag should not be tested unconditionally with NLMSG_DONE because the
rtnl_dump_filter_l helper is used not only for diag talks but overall
the iproute2, thus I need to test for status only for specified requests.
And I need to narrow down why not all device bound interfaces are killed
in one pass.

	Cyrill
