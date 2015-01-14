From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: fix setlink/dellink notifications
Date: Wed, 14 Jan 2015 12:57:12 -0800
Message-ID: <54B6D828.3030204@cumulusnetworks.com>
References: <1421218123-18346-1-git-send-email-roopa@cumulusnetworks.com> <20150114194137.GC2105@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com,
	john.fastabend@gmail.com, jhs@mojatatu.com, sfeldma@gmail.com,
	jiri@resnulli.us, wkok@cumulusnetworks.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:52037 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbbANU5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 15:57:14 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so12790291pad.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 12:57:14 -0800 (PST)
In-Reply-To: <20150114194137.GC2105@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/15, 11:41 AM, Thomas Graf wrote:
> On 01/13/15 at 10:48pm, roopa@cumulusnetworks.com wrote:
>> 2) Generate one notification from master and the other notification from
>>     self (This seems to be ideal):
>>       For master: the master driver will send notification (bridge in this
>> 	example)
>>       For self: the self driver will send notification (rocker in the above
>> 	example. It can use helpers from rtnetlink.c to do so. Like the
>> 	ndo_dflt_bridge_getlink api).
>>
>> This patch implements 2) (leaving the 'rtnl_bridge_notify' around to be used
>> with 'self').
>>
>> CC'ing others who might be affected by this change for review.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> I haven't digested this line by line yet but I agree that what you
> describe above would be a good end state.
>
> If I read the patch correctly then we would omit one notification
> for the master case.
yes, correct.
> Were both notifications exactly identical
> previously?
> This has the chance of breaking existing users terribly.

yes AFAICT, because

rtnl_bridge_notify() from rtnetlink.c for bridge  results in calling 
br_fill_ifinfo() via ndo_bridge_getlink()
and the notification from bridge driver br_ifinfo_notify() also ends up 
calling br_fill_ifinfo().

Thanks,
Roopa
