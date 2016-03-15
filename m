From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Tue, 15 Mar 2016 01:08:44 -0700
Message-ID: <56E7C30C.7020009@cumulusnetworks.com>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com> <20160314145144.GE2346@nanopsycho.orion> <56E706C3.4030808@cumulusnetworks.com> <20160314190435.GA23419@nanopsycho.orion> <56E7AA96.8030305@cumulusnetworks.com> <20160315072856.GA2263@nanopsycho.orion> <56E7BC0B.3070107@cumulusnetworks.com> <20160315075223.GB2263@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33116 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870AbcCOIIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 04:08:46 -0400
Received: by mail-pf0-f180.google.com with SMTP id 124so18742128pfg.0
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 01:08:46 -0700 (PDT)
In-Reply-To: <20160315075223.GB2263@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/16, 12:52 AM, Jiri Pirko wrote:
> Tue, Mar 15, 2016 at 08:38:51AM CET, roopa@cumulusnetworks.com wrote:
>>
[snip]
>> how does it matter if we have reached an agreement that the struct is required ?.
>> unlike other messages, a filter_mask is an important and must attribute for
>> stats. If you are worried about us running out of bits in u32, the netlink attribute you will
>> define for the filter_mask will also be u32 to begin with.
> No, you are missing the point:

I understood what you meant the first time...(to which i did comment if you really wanted a u8 for every filter attribute).

>
> enum {
> 	IFLA_STATS_UNSPEC,
> 	IFLA_STATS_FILTER, /* nest */
> 	IFLA_STATS_LINK64,
> 	IFLA_STATS_INET6,
> 	__IFLA_STATS_MAX,
> };
>
> #define IFLA_STATS_MAX (__IFLA_STATS_MAX - 1)
>
> enum {
> 	IFLA_STATS_FILTER_UNSPEC,
> 	IFLA_STATS_FILTER_LINK64, /* flag */
> 	IFLA_STATS_FILTER_INET6, /* flag */
> 	...
> 	IFLA_STATS_FILTER_WHATEVER, /* flag */
> 	__IFLA_STATS_FILTER_MAX,
> };
>
> #define IFLA_STATS_FILTERMAX (__IFLA_STATS_FILTER_MAX - 1)

Apart from the usability concern i have described earlier, this just seems an overkill ...having to redefine every attribute.
