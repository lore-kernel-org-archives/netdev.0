From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 3/3] bonding: Improve IGMP join processing
Date: Tue, 6 Mar 2007 14:32:00 -0800
Message-ID: <OF686AF962.8A54116E-ON88257296.007AF408-88257296.007BC448@us.ibm.com>
References: <bdfc5d6e0703061244q2bc9403cs7c6321136fd8e4e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: bonding-devel@lists.sourceforge.net,
	"Brian Haley" <brian.haley@hp.com>, fubar@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: "Andy Gospodarek" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:42749 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbXCFWcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 17:32:06 -0500
In-Reply-To: <bdfc5d6e0703061244q2bc9403cs7c6321136fd8e4e0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks to me like "rejoin" is essentially ip_mc_up(), and it'd be better
to call that than add a nearly identical function.

Also, real interfaces already do gratuitous IGMP advertisements when
they are bounced (the reason there is an ip_mc_up()). Could bonding,
when failing over, simply mark the master interface as down, switch, and
then mark the master as up again? In addition to doing the right
thing for both IPv4 and IPv6 multicasting w/o any code changes in those
layers, it may have similar benefits for ARP and neighbor discovery, 
right?
Maybe not-- haven't looked at it...

One down side for IPv6 (which apparently bonding doesn't support) is that
static addresses are lost when the device goes down, but that's a 
difference
form IPv4 that should be fixed.
                                                +-DLS

