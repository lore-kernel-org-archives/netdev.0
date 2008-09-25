From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: /proc/net/igmp group address encoding
Date: Thu, 25 Sep 2008 00:35:40 -0700
Message-ID: <OFC83E5520.1D27DF52-ON882574CF.0028A6D4-882574CF.0029B829@us.ibm.com>
References: <b25312890809242344n11e61c80w1bf761c55c29a65e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	"Pekka Savola" <pekkas@netcore.fi>
To: "Rami Rosen" <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:38135 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbYIYHfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 03:35:43 -0400
In-Reply-To: <b25312890809242344n11e61c80w1bf761c55c29a65e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 09/24/2008 11:44:45 PM:

> Hi,
> 
> - I had noticed a long ago that the IP addresses under
>  /proc/net/igmp are in Hexa format. I am preparing a patch to fix it
> and it will be send very soon.

I don't think we can do that, since I believe netstat expects
to see this the way it is. Maybe if we change netstat to support
both and wait a year for all distros to get it... :-)


> So indeed , the count (mc_count of netdevice) shows both IPv4 and IPv6 
igmp
> groups, but in current implementation it is not immediate
> to change it. Currently, net_device struct does not have specific
> fields for ipv4 or ipv6.  One way of preparing a patch
> is to change net_device to have mc_count4 and mc_count6;
> I am really willing to prepare such a patch, but I am not sure such a
> change in net_device is a proper and a justified
> change to do.

        These belong with mc_list in inet6_dev and in_device. Really,
I'd just add "mc_count" as a field right next to mc_list and inc/dec
it when calling the group join/leave functions-- use the list lock
to protect it. The structure it's in distinguishes the protocol,
and the names are otherwise common.

                                                                +-DLS

