From: Holger Brunck <holger.brunck@keymile.com>
Subject: Re: [PATCH] net, bridge: print log message after state changed
Date: Fri, 18 Nov 2011 10:20:10 +0100
Message-ID: <4EC6234A.1030002@keymile.com>
References: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com><20111114.003702.1097206603722725705.davem@davemloft.net><1321254211.4072.29.camel@pc005091.de.keymile.net><20111114.020749.1176229013272872343.davem@davemloft.net>
	 <20111117192353.GD2051622@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com, bridge@lists.linux-foundation.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.de.keymile.com ([195.8.104.1]:43194 "HELO
	mail.de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756535Ab1KRJV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 04:21:26 -0500
In-Reply-To: <20111117192353.GD2051622@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2011 08:23 PM, David Lamparter wrote:
> On Mon, Nov 14, 2011 at 02:07:49AM -0500, David Miller wrote:
>>>> The message is therefore appropriately timed as far as I'm concerned.
>>>>
>>>
>>> It's not.
>>>
>>> Please test: create a bridge with STP disabled, add an interface to the
>>> bridge and set that interface down. You get the message "... entering
>>> forwarding state". That's wrong because it's "about to enter" disabled
>>> state some lines later.
>>>
>>> All other (4) calls to br_log_state are located after the state change,
>>> see for example br_stp_enable_port() just some lines above the patch.
>>
>> I would never expect an "entering" message to print out after the event
>> happens, and in fact I'd _always_ want to see it beforehand so that if
>> the state change caused a crash or similar it'd be that much easier
>> to pinpoint the proper location.
> 
> There seems to be a misunderstanding here. The patch effectively does:
> -       br_log_state(p);
>         p->state = BR_STATE_DISABLED;
> +       br_log_state(p);
> 
> and the issue it is trying to fix is not the timing but rather the code
> printing the wrong (old, now-left) state.
> 

Yes exactly this is the problem. We got confusing state messages in the current
implementation.

> I do agree that the log message should be printed before anything
> happens, so, Holger, can you brew a patch that does that?
> 

This can't be changed easily. Because in some situations we don't know which
state we will enter at the entry point of the function.

For example  br_make_forwarding does something like
if ..
  p->state = STATE_A
else if ...
  p->state = STATE_B
....

So my approach would be to change the log message from "port entering state" to
"port entered state" and print it out after the state changed.

Regards
Holger
