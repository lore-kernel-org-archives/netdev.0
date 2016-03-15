From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 15 Mar 2016 09:24:17 +0100
Message-ID: <20160315082417.GC2263@nanopsycho.orion>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com>
 <20160314145144.GE2346@nanopsycho.orion>
 <56E706C3.4030808@cumulusnetworks.com>
 <20160314190435.GA23419@nanopsycho.orion>
 <56E7AA96.8030305@cumulusnetworks.com>
 <20160315072856.GA2263@nanopsycho.orion>
 <56E7BC0B.3070107@cumulusnetworks.com>
 <20160315075223.GB2263@nanopsycho.orion>
 <56E7C30C.7020009@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36629 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933849AbcCOIYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 04:24:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id l68so2224877wml.3
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 01:24:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <56E7C30C.7020009@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 15, 2016 at 09:08:44AM CET, roopa@cumulusnetworks.com wrote:
>On 3/15/16, 12:52 AM, Jiri Pirko wrote:
>> Tue, Mar 15, 2016 at 08:38:51AM CET, roopa@cumulusnetworks.com wrote:
>>>
>[snip]
>>> how does it matter if we have reached an agreement that the struct is required ?.
>>> unlike other messages, a filter_mask is an important and must attribute for
>>> stats. If you are worried about us running out of bits in u32, the netlink attribute you will
>>> define for the filter_mask will also be u32 to begin with.
>> No, you are missing the point:
>
>I understood what you meant the first time...(to which i did comment if you really wanted a u8 for every filter attribute).

You mentioned "u32 attr" in last reply and that is clearly something I
didn't suggested and wasn't talking about at all, so I had to make
things clear.


>
>>
>> enum {
>> 	IFLA_STATS_UNSPEC,
>> 	IFLA_STATS_FILTER, /* nest */
>> 	IFLA_STATS_LINK64,
>> 	IFLA_STATS_INET6,
>> 	__IFLA_STATS_MAX,
>> };
>>
>> #define IFLA_STATS_MAX (__IFLA_STATS_MAX - 1)
>>
>> enum {
>> 	IFLA_STATS_FILTER_UNSPEC,
>> 	IFLA_STATS_FILTER_LINK64, /* flag */
>> 	IFLA_STATS_FILTER_INET6, /* flag */
>> 	...
>> 	IFLA_STATS_FILTER_WHATEVER, /* flag */
>> 	__IFLA_STATS_FILTER_MAX,
>> };
>>
>> #define IFLA_STATS_FILTERMAX (__IFLA_STATS_FILTER_MAX - 1)
>
>Apart from the usability concern i have described earlier, this just seems an overkill ...having to redefine every attribute.

I don't hear the usability concern. User knows how to compose/parse
attrs, no problem there.

You just add flag attr as if you add bit in u32 mask. The same thing.

I don't understand why you say this is an "overkill". I believe that
this is the correct way to do.
