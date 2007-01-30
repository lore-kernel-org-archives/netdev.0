From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: igmp: possible NULL dereference after GFP_ATOMIC allocation?
Date: Tue, 30 Jan 2007 03:34:18 -0800
Message-ID: <OF52248A96.35A5CA3C-ON88257273.003E5791-88257273.003F9122@us.ibm.com>
References: <20070130105701.GA6015@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60839 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965114AbXA3LeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 06:34:21 -0500
In-Reply-To: <20070130105701.GA6015@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey,
        I think you're correct-- looks like it needs:

        if (!skb)
                return NULL;

just before the skb_put(), since an allocation (and failure)
could occur in either the igmpv3_newpack() call or in add_grhead().
        Also, similar code in net/ipv6/mcast..c.

        Will you be submitting the patch?

                                        +-DLS

