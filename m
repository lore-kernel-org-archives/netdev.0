From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next v3 1/1] net: Support for switch port
 configuration
Date: Fri, 19 Dec 2014 09:12:16 +0100
Message-ID: <20141219081216.GB1848@nanopsycho.orion>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD9F56@IRSMSX108.ger.corp.intel.com>
 <5492FAD4.7070308@gmail.com>
 <20141219003510.GC16239@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	"Varlese, Marco" <marco.varlese@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:40657 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbaLSIMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 03:12:19 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so1077732wiw.2
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 00:12:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141219003510.GC16239@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 19, 2014 at 01:35:10AM CET, tgraf@suug.ch wrote:
>On 12/18/14 at 08:03am, John Fastabend wrote:
>> On 12/18/2014 07:30 AM, Varlese, Marco wrote:
>> Could you also document the attributes. I think they are mostly
>> clear but what is IFLA_SW_LOOPBACK. It will help later when we
>> try to read the code in 6months and implement drivers.
>> 
>> I am thinking something like
>> 
>> /* Switch Port Attributes section
>>  * IFLA_SW_LEARNING - turns learning on in the bridge
>>  * IFLA_SW_LOOPBACK - does something interesting
>> 
>>  [...]
>>  */
>
>+1. I would even ask for more than that. While clear in the bridge
>context, "learning" for this API targetting multi layer switches
>is ambigious. The expectation towards the driver must be crystical
>clear.
>
>> >+
>> >+enum {
>> >+	IFLA_SW_UNSPEC,
>> >+	IFLA_SW_LEARNING,
>> 
>> Can you address Roopa's feedback. I'm also a bit confused by the
>> duplication.
>
>Agreed. Can we decide on the ndo first and then build the APIs on
>top of that? While I agree that we should have a non-bridge based
>Netlink API, the underlying ndo should be the same.

Maybe we can use this kind of ndos (proposed by this patch) and call it
for switchdevs instead of bridge_get/setlink. Would make sense to me.
single set of ndos, many possible users (userspace/in-kernel).
bridge_get/setlink would be just a wrapper for this.

>
>> >+static const struct nla_policy ifla_sw_attr_policy[IFLA_SW_ATTR_MAX+1] = {
>> >+	[IFLA_SW_LEARNING]	= { .type = NLA_U64 },
>> >+	[IFLA_SW_LOOPBACK]	= { .type = NLA_U64 },
>> >+	[IFLA_SW_BCAST_FLOODING] = { .type = NLA_U64 },
>> >+	[IFLA_SW_UCAST_FLOODING] = { .type = NLA_U64 },
>> >+	[IFLA_SW_MCAST_FLOODING] = { .type = NLA_U64 },
>> >+};
>> 
>> Why U64 values? What would we pass in these? Are these just boolean
>> bits? Maybe the annotation above will help me understand this.
>
>I think the intent is to keep the ndo API as simple as possible
>but I agree that this is wasteful. I gave this feedback on v2 already.
