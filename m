From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next 1/4] rtnetlink: Add get_link_af_size_filtered
 to rtnl_af_ops
Date: Wed, 14 Oct 2015 14:46:52 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC350F7ACC30@ORSMSX101.amr.corp.intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
	<1444802314-28830-2-git-send-email-ronen.arad@intel.com>
 <20151014115518.071a3996@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Jiri Benc <jbenc@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42076 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753671AbbJNOq7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 10:46:59 -0400
In-Reply-To: <20151014115518.071a3996@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Jiri Benc [mailto:jbenc@redhat.com]
>Sent: Wednesday, October 14, 2015 2:55 AM
>To: Arad, Ronen
>Cc: netdev@vger.kernel.org
>Subject: Re: [PATCH net-next 1/4] rtnetlink: Add get_link_af_size_filtered to
>rtnl_af_ops
>
>On Tue, 13 Oct 2015 22:58:31 -0700, Ronen Arad wrote:
>> --- a/include/net/rtnetlink.h
>> +++ b/include/net/rtnetlink.h
>> @@ -130,6 +130,8 @@ struct rtnl_af_ops {
>>  						    const struct nlattr *attr);
>>  	int			(*set_link_af)(struct net_device *dev,
>>  					       const struct nlattr *attr);
>> +	size_t			(*get_link_af_size_filtered)(const struct
>net_device *dev,
>> +							     u32 ext_filter_mask);
>>  };
>
>There's not much point in having two callbacks doing essentially the
>same. Why you just don't add the new parameter to the existing
>get_link_af_size? Looking at what the patch 3 does, the current
>implementations of the callback can just ignore the new parameter and
>bridge can remove the current br_get_link_af and rename
>br_get_link_af_size_filtered to br_get_link_af.
[@Ronen] I agree with you about br_netlink. There was no need for both
so I removed br_get_link_af. Changing get_link_af_size signature, however,
will require change in other unrelated locations. I wanted to avoid that. The affected location are:
net/ipv4/devinet.c:2374:	.get_link_af_size = inet_get_link_af_size,
net/ipv6/addrconf.c:5868:	.get_link_af_size = inet6_get_link_af_size,

If there is a consensus that adding ext_filter_mask argument to
get_link_af is preferred, I'll submit a v2.

>
> Jiri
>
>--
>Jiri Benc
