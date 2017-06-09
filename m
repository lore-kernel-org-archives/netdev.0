From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH v2 net-next] Ipvlan should return an error when an
 address is already in use.
Date: Fri, 9 Jun 2017 10:25:01 -0700
Message-ID: <20170609172501.GB2766@templeofstupid.com>
References: <20170608201214.GB2553@templeofstupid.com>
 <20170609.122646.100677990071641882.davem@davemloft.net>
 <20170609171310.GA2766@templeofstupid.com>
 <20170609.131510.1262676940920520377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kjlx@templeofstupid.com, maheshb@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:53091 "EHLO
        homiemail-a80.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751527AbdFIRY7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 13:24:59 -0400
Received: from homiemail-a80.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a80.g.dreamhost.com (Postfix) with ESMTP id C78BB6004D35
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 10:24:58 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a80.g.dreamhost.com (Postfix) with ESMTPSA id A4DE16004D1D
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 10:24:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170609.131510.1262676940920520377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 01:15:10PM -0400, David Miller wrote:
> From: Krister Johansen <kjlx@templeofstupid.com>
> Date: Fri, 9 Jun 2017 10:13:10 -0700
> 
> > On Fri, Jun 09, 2017 at 12:26:46PM -0400, David Miller wrote:
> >> From: Krister Johansen <kjlx@templeofstupid.com>
> >> Date: Thu, 8 Jun 2017 13:12:14 -0700
> >> 
> >> > The ipvlan code already knows how to detect when a duplicate address is
> >> > about to be assigned to an ipvlan device.  However, that failure is not
> >> > propogated outward and leads to a silent failure.
> >> > 
> >> > Introduce a validation step at ip address creation time and allow device
> >> > drivers to register to validate the incoming ip addresses.  The ipvlan
> >> > code is the first consumer.  If it detects an address in use, we can
> >> > return an error to the user before beginning to commit the new ifa in
> >> > the networking code.
> >> > 
> >> > This can be especially useful if it is necessary to provision many
> >> > ipvlans in containers.  The provisioning software (or operator) can use
> >> > this to detect situations where an ip address is unexpectedly in use.
> >> > 
> >> > Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
> >> 
> >> Ok, applied, thank you.
> > 
> > Thanks, did this look otherwise alright?
> 
> Yes, I was mildly unsatisfied with the ipv6 addrconf situation but I know
> very well about that, and those kinds of addresses aren't of interest
> for what you are trying to achieve right?

That's correct.  I'm basically trying to catch the case where 'ip addr'
or its equivalent rtnetlink invocation manually configure an ip address
on a ipvlan.

-K
