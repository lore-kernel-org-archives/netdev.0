From: David Miller <davem@davemloft.net>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 14:12:00 -0400 (EDT)
Message-ID: <20140422.141200.1878796491205301689.davem@davemloft.net>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
	<1398189799.7767.80.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dgibson@redhat.com, netdev@vger.kernel.org, benve@cisco.com,
	ssujith@cisco.com, govindarajulu90@gmail.com, neepatel@cisco.com,
	nistrive@cisco.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaDVSMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 14:12:03 -0400
In-Reply-To: <1398189799.7767.80.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 22 Apr 2014 19:03:19 +0100

> On Tue, 2014-04-22 at 14:14 +1000, David Gibson wrote:
>> I believe I've found a problem with netlink handling which can be
>> triggered on Cisco enic devices with a large number (30-40) of virtual
>> functions.  I believe this is the cause of a real customer problem
>> we've seen.
>> 
>>  * When requesting a list of interfaces with RTM_GETLINK, enic devices
>>    (and currently, _only_ enic devices) report IFLA_VF_PORTS
>>    information 
>> 
>>  * IFLA_VF_PORTS information has at least 90 bytes ber virtual function
>> 
>>  * Unlike IFLA_VFINFO_LIST, the ports information is always reported,
>>    regardless of the setting of the IFLA_EXT_MASK parameter
> [...]
> 
> So I think you should make reporting of IFLA_VF_PORTS dependent on the
> same flag as IFLA_VFINFO_LIST.

I think that's what we'll have to do.
