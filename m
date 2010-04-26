From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 12:57:06 -0700
Message-ID: <C7FB3E22.2BAEE%scofeldm@cisco.com>
References: <C7FB3747.2BAAA%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <chrisw@redhat.com>, <arnd@arndb.de>
To: Scott Feldman <scofeldm@cisco.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:1079 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab0DZT5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 15:57:13 -0400
In-Reply-To: <C7FB3747.2BAAA%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/26/10 12:27 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:
> On 4/24/10 12:19 AM, "David Miller" <davem@davemloft.net> wrote:
>> Also, I think it's reasonable to fetch the current profile in use, so
>> GETLINK ought to report these things.  To make it generic we can
>> maintain the settings given to us in software, hung off of the netdev
>> struct, and simply report that during GETLINK.
> 
> We'd need an array of struct ifla_vf_port_profile hanging off of netdev, one
> element for each VF.  That seems like a lot of mem hanging off of netdev,
> and we'd have to define a MAX_VF to size the array.  How about a
> ndo_get_vf_port_profile() that the netdev fills in, and the netdev keeps the
> data in it's private area?  That's how ndo_get_vf_config() is working.

Hmmm....even that isn't so nice because the port-profile info for all VFs is
going to get stuffed into the RTM_GETLINK skb, and I assume there are limits
on the skb return size.

Here's a proposal:

Currently we have RTM_GETLINK for

    ip link show [ DEVICE ]

This dumps everything for the DEVICE including info for each VF.  Let's
modify RTM_GETLINK to look like this:

    ip link show [ DEVICE [ vf NUM] ]

If you don't give the optional vf NUM you get base dump on DEVICE.  If you
give vf NUM, you get the VF-specific dump.  This scales much better with the
number of VFs.  

(Number of VFs can easily be > 128 in some designs).

Comments?

-scott

