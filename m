From: David Miller <davem@davemloft.net>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 20:59:39 -0400 (EDT)
Message-ID: <20140422.205939.850933099313805079.davem@davemloft.net>
References: <1398189799.7767.80.camel@deadeye.wl.decadent.org.uk>
	<20140422.141200.1878796491205301689.davem@davemloft.net>
	<20140423092606.c73425b64d127b8f94469fcb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org, benve@cisco.com,
	ssujith@cisco.com, govindarajulu90@gmail.com, neepatel@cisco.com,
	nistrive@cisco.com
To: dgibson@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaDWA7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 20:59:41 -0400
In-Reply-To: <20140423092606.c73425b64d127b8f94469fcb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Gibson <dgibson@redhat.com>
Date: Wed, 23 Apr 2014 09:26:06 +1000

> On Tue, 22 Apr 2014 14:12:00 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Tue, 22 Apr 2014 19:03:19 +0100
>> 
>> > On Tue, 2014-04-22 at 14:14 +1000, David Gibson wrote:
>> >> I believe I've found a problem with netlink handling which can be
>> >> triggered on Cisco enic devices with a large number (30-40) of virtual
>> >> functions.  I believe this is the cause of a real customer problem
>> >> we've seen.
>> >> 
>> >>  * When requesting a list of interfaces with RTM_GETLINK, enic devices
>> >>    (and currently, _only_ enic devices) report IFLA_VF_PORTS
>> >>    information 
>> >> 
>> >>  * IFLA_VF_PORTS information has at least 90 bytes ber virtual function
>> >> 
>> >>  * Unlike IFLA_VFINFO_LIST, the ports information is always reported,
>> >>    regardless of the setting of the IFLA_EXT_MASK parameter
>> > [...]
>> > 
>> > So I think you should make reporting of IFLA_VF_PORTS dependent on the
>> > same flag as IFLA_VFINFO_LIST.
>> 
>> I think that's what we'll have to do.
> 
> Ok, makes logical sense.
> 
> But does anyone know what tools make use of the IFLA_VF_PORTS
> information?  Do they set the IFLA_EXT_MASK already?

iproute2 makes use of IFLA_VF_PORTS and sets IFLA_EXT_MASK
unconditionally in rtnl_wilddump_request().

libvirt also makes use of IFLA_VF_PORTS, and also unconditionally
sets IFLA_EXT_MASK in virNetDevLinkDump.

I only did a quick search and can't find any more users.
