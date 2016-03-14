From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 14 Mar 2016 21:22:02 +0100
Message-ID: <20160314202202.GB23419@nanopsycho.orion>
References: <20160314145144.GE2346@nanopsycho.orion>
 <56E706C3.4030808@cumulusnetworks.com>
 <20160314190435.GA23419@nanopsycho.orion>
 <20160314.155640.1574437783302725000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34744 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351AbcCNUWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 16:22:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id p65so17451105wmp.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 13:22:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160314.155640.1574437783302725000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 14, 2016 at 08:56:40PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Mon, 14 Mar 2016 20:04:35 +0100
>
>> I believe that using *any* structs to send over netlink is a mistake.
>> Netlink is capable to transfer everything using attrs. Easy to compose,
>> easy to parse. easy to extend. Couple of more bytes in the message? So what?
>> For newly introduced things, I suggest to do this properly.
>
>It is not so straight-forward.
>
>What to put into the header is a tradeoff.
>
>The most basic use cases should be as efficient as possible, and if we
>can put reasonable knobs into the base commend header we should do that
>as avoiding attribute processing makes things faster.

Faster in which matter? Regarding the user app complexicity, I think that
processing attrs is very simple and straightforward. I might be missing
something very obvious, but I don't think that processing header struct
is that much easier that it advocates for the unclean approach.

I personally believe that introducing possibility to pass Netlink
headers was a mistake from the very beginning. If we have clean Netlink
interface, why to pollute that with ioclt-like struct approach. Okay,
the mistake was done. But as I said, for the future usage, I believe
that it should be avoided.


>
>And I think in this case it is reasonable to put the mask in there.
>
>The only problem I see with this series is the naming of the netlink
>command (it isn't a "new" operation, and the "del" is unused).
>
>Maybe the suggestion to use just "GET" as the name is ok.

+1
