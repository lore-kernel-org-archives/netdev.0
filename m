From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next 0/4] Rightsize IFLA_AF_SPEC size calculation
Date: Thu, 15 Oct 2015 01:32:02 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC350F7AD3FC@ORSMSX101.amr.corp.intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
 <20151014.184411.1172845560887990370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17296 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133AbbJOBcD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:32:03 -0400
In-Reply-To: <20151014.184411.1172845560887990370.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, October 14, 2015 6:44 PM
>To: Arad, Ronen
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH net-next 0/4] Rightsize IFLA_AF_SPEC size calculation
>
>From: Ronen Arad <ronen.arad@intel.com>
>Date: Tue, 13 Oct 2015 22:58:30 -0700
>
>> if_nlmsg_size() overestimates the minimum allocation size of netlink dump
>> request (when called from rtnl_calcit()) or the size of the message (when
>called
>> from rtnl_getlink()). This is because ext_filter_mask is not supported by
>> rtnl_link_get_af_size() and rtnl_link_get_size().
>>
>> The over-estimation is significant when at least one netdev has many VLANs
>> configured (8 bytes for each configured VLAN).
>>
>> This patch-set "rightsizes" the protocol specific attribute size calculation
>by
>> propagating ext_filter_mask to rtnl_link_get_af_size() and adding optional
>> filtering aware get_af_size_filtered op in struct rtnl_af_ops. Bridge
>module,
>> which already used filtering aware sizing for notification, is enhanced to
>do
>> the same for netlink dump requests.
>
>There are only three implementations of get_link_af_size, so please just
>simply
>change it's signature by adding the ext_filter_mask parameter instead of
>creating
>a completely new operation.
[@Ronen] I've already submitted a V2 that does that in a simplified
single part patch.
