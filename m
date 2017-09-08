From: soohoon.lee@f5.com
Subject: IFA_F_OPTIMISTIC is not supported?
Date: Fri, 08 Sep 2017 10:29:03 -0400
Message-ID: <59b2a92f.G2i6Z3JSoznmqvuW%soohoon.lee@f5.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.f5.com ([104.219.104.14]:59145 "EHLO mail13.f5.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932091AbdIHOjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 10:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtm_newaddr masks off OPTIMISTIC.

inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
...
        /* We ignore other flags so far. */
        ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
                     IFA_F_NOPREFIXROUTE;

Is there any problem or not allowed?

I need to do something like adding a route for the address after adding the address but fails because the address is not useable yet.
I tried NODAD but there's still little delay until IFA_F_TENTATIVE is cleared.
	- rtm_newaddr sets IFA_F_TENTATIVE
	- set a timer for dad start with delay=0
	- some delay
	- dad starts but ends immediately because of NODAD flag, and clears TENTATIVE.

And it looks like OPTIMISTIC does what I need but kind of disabled like the code above.

Thanks,
Soohoon.
