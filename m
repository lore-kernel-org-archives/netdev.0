From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH 1/5] geneve: remove MODULE_ALIAS_RTNL_LINK from
 net/ipv4/geneve.c
Date: Fri, 3 Apr 2015 14:17:55 +0200
Message-ID: <20150403121755.GC16847@nanopsycho.orion>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-2-git-send-email-linville@tuxdriver.com>
 <20150402163919.7b07039a@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33033 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbbDCMR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 08:17:58 -0400
Received: by wgin8 with SMTP id n8so20367690wgi.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 05:17:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150402163919.7b07039a@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 03, 2015 at 01:39:19AM CEST, stephen@networkplumber.org wrote:
>On Thu,  2 Apr 2015 15:17:02 -0400
>"John W. Linville" <linville@tuxdriver.com> wrote:
>
>> This file is essentially a library for implementing the geneve
>> encapsulation protocol.  The file does not register any rtnl_link_ops,
>> so the MODULE_ALIAS_RTNL_LINK macro is inappropriate here.
>> 
>> Signed-off-by: John W. Linville <linville@tuxdriver.com>
>> ---
>>  net/ipv4/geneve.c | 1 -
>>  1 file changed, 1 deletion(-)
>> 
>> diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
>> index 5a4828ba05ad..ba5283adbee8 100644
>> --- a/net/ipv4/geneve.c
>> +++ b/net/ipv4/geneve.c
>> @@ -450,4 +450,3 @@ module_exit(geneve_cleanup_module);
>>  MODULE_LICENSE("GPL");
>>  MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
>>  MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
>> -MODULE_ALIAS_RTNL_LINK("geneve");
>
>ok but then how does it get autoloaded?

There is no "struct rtnl_link_ops" defined for this. Therefore this does
not have any sense. User might use rtnl to load the module, but why?
That is clearly a bug which John is fixing.
