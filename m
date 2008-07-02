From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: locking requirements when calling dev_set_mtu()
Date: Wed, 2 Jul 2008 09:41:40 -0700
Message-ID: <20080702094140.032efd28@extreme>
References: <20080702085409.GA13098@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, fubar@us.ibm.com,
	ogerlitz@voltaire.com, Roland Dreier <rdreier@cisco.com>,
	general-list <general@lists.openfabrics.org>
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35532 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbYGBQls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 12:41:48 -0400
In-Reply-To: <20080702085409.GA13098@mtls03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jul 2008 11:54:09 +0300
Eli Cohen <eli@dev.mellanox.co.il> wrote:

> Hi,
> 
> I have the need to change the MTU of IP over IB from the driver code
> and not from the shell. Looking for the right way to do it I came
> across the dev_set_mtu() which seems appropriate as it handles all
> notifications too. However, it is not clear to me whether I have to
> wrap the call to dev_set_mtu() with any locks. Specifically, I was
> referred to a mail thread that suggests that I have to use
> rtnl_lock()/rtnl_unlock():
> http://marc.info/?l=linux-netdev&m=121201324611292&w=2
> 
> With reference to the above URL, I would say that it is possible for
> me to hit to the assertion ASSERT_RTNL() if I don't take rtnl_lock
> prior to calling dev_set_mtu(). However I don't hit it, though I can't
> count on that there will not be a case that any function registered
> for notification would expect to see the lock acquired.
> 

You need to call rtnl_lock() so device drivers get consistent locking.
