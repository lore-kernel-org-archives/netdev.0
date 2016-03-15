From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Tue, 15 Mar 2016 00:02:43 -0700
Message-ID: <56E7B393.5000400@cumulusnetworks.com>
References: <20160314145144.GE2346@nanopsycho.orion> <56E706C3.4030808@cumulusnetworks.com> <20160314190435.GA23419@nanopsycho.orion> <20160314.155640.1574437783302725000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33571 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbcCOHCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 03:02:45 -0400
Received: by mail-pf0-f172.google.com with SMTP id 124so16261819pfg.0
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 00:02:45 -0700 (PDT)
In-Reply-To: <20160314.155640.1574437783302725000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/14/16, 12:56 PM, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Mon, 14 Mar 2016 20:04:35 +0100
>
>> I believe that using *any* structs to send over netlink is a mistake.
>> Netlink is capable to transfer everything using attrs. Easy to compose,
>> easy to parse. easy to extend. Couple of more bytes in the message? So what?
>> For newly introduced things, I suggest to do this properly.
> It is not so straight-forward.
>
> What to put into the header is a tradeoff.
>
> The most basic use cases should be as efficient as possible, and if we
> can put reasonable knobs into the base commend header we should do that
> as avoiding attribute processing makes things faster.
yes, i have recently realized this after looking at all other message
types and the userspace part of it. It does make the default message much simpler.
>
> And I think in this case it is reasonable to put the mask in there.
>
> The only problem I see with this series is the naming of the netlink
> command (it isn't a "new" operation, and the "del" is unused).
I just replied to the other responses on this: I did declare all three because
rtnetlink_rcv_msg seems to expect the get message at a particular offset
 (when it derives kind from nlmsg_type). But, i can fix it accordingly.
>
> Maybe the suggestion to use just "GET" as the name is ok.
I am thinking RTM_NEWSTATS is ok here. Because from userspace you are looking at message per interface
as a separate stats object. It also adheres to existing convention.

Besides, jamals original request/suggestion also had periodic stats notification to user-space...,
in which case it would be more appropriate to use RTM_NEWSTATS (if we implement it in the future ofcourse).

And from userspace perspective, dumps and notifications should come in with the same msg type.
userspace sees it as a stats message and does not care if it came as part of a dump or a notification.
also, user space netlink caches expect this (i work with libnl a lot and it is based on this assumption).
so, RTM_NEWSTATS seems more appropriate here.

But, if you have stronger reasons for RTM_GETSTATS, sure, pls let me know.

Thanks,
Roopa
