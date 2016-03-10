From: Jonathan Thibault <jonathan@navigue.com>
Subject: Re: gretap default MTU question
Date: Thu, 10 Mar 2016 09:30:50 -0500
Message-ID: <56E1851A.2030407@navigue.com>
References: <56E05C8F.1060901@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:50184 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbcCJOaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 09:30:52 -0500
Received: from [192.168.7.182] (unknown [74.117.40.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.navigue.com (Postfix) with ESMTPSA id BFA931A0031
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 09:30:50 -0500 (EST)
In-Reply-To: <56E05C8F.1060901@navigue.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/16 12:25 PM, Jonathan Thibault wrote:
> Hello good people of netdev,
>
> When setting up gretap devices like so:
>
> ip link add mydev type gretap remote 1.1.1.1 local 2.2.2.2 nopmtudisc
>
> I'm observing two different behavior:
>
> - On system A, the MTU of 'mydev' is set to the MTU of the 'parent'
> interface (currently 1600) minus 38. All other interfaces on that system
> have a default MTU of 1500, only the parent was forced to 1600 to avoid
> fragmentation.  So 'mydev' accurately figures out that its MTU is 1562.
>
> - On system B, with the 'parent' interface MTU set to 1600 and all other
> defaulting to 1500 (same situation as A), the MTU of 'mydev' gets set to
> 1462.
>
> I'm trying to figure out which behavior is normal and what mechanism (if
> any) causes the MTU to be set differently.  In both cases the 'parent'
> device has an MTU of 1600.  The code in ip_gre.c does this:
>
> dev->mtu = ETH_DATA_LEN - t_hlen - 4;
>
> In this case, system B would have the expected behavior and I need some
> way to explain what goes on with system A.
>
> Of course I can force the MTU on system B but I was rather pleased with
> the 'magic' on system A.
>
> If anyone here familiar with this code can offer an explanation, it
> would greatly ease my curiosity.
>
> Jonathan
Replying to myself to leave a trace.

Turns out that the MTU of the gretap device is based on the MTU of the
interface that has a route to the 'remote' address.  In my specific
case, it used the default route on system B and a static route on system
A.  The cause of the discrepancy was a missing route.

Jonathan
