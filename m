From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 0/2] fix generic netlink locking issue(s)
Date: Wed, 21 Aug 2013 15:53:54 -0700
Message-ID: <CALnjE+qtGXHkqxfSPWi5nsqA=fLkxijxDLDha=Z+YL=eQxxDmQ@mail.gmail.com>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	<52150F87.90207@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:40199 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751963Ab3HUWxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 18:53:55 -0400
Received: by mail-qa0-f46.google.com with SMTP id bq6so758615qab.19
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 15:53:54 -0700 (PDT)
In-Reply-To: <52150F87.90207@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This looks like more general problem and not specific to genl_ctrl
family. I have couple of fixes for issues you are seeing, I will send
out those patches soon.

On Wed, Aug 21, 2013 at 12:05 PM, Oliver Hartkopp
<socketcan@hartkopp.net> wrote:
> On 21.08.2013 16:08, Johannes Berg wrote:
>> Here's another attempt at fixing the genetlink locking issue,
>> hopefully better tested this time. Sorry about the mess the
>> previous version caused.
>>
>> I really didn't find a way to "simply" add locking, no matter
>> which way I turn genetlink is special because it would then use
>> the same locks "inside" and "outside" the generic netlink family;
>> "inside" because I'm trying to protect the otherwise unlocked
>> dump call, and "outside" because it itself is a generic netlink
>> family so needs to protect things there.
>>
>> As a result, I've turned to RCU and (hopefully) made it safe.
>> The unregistration can get fairly expensive with all the calls
>> to synchronize_rcu(), but I don't see any better way, and it's
>> hopefully really rare.
>>
>> The only place that now uses RCU is ctrl_dumpfamily(), but it'd
>> be possible to use it in other places. I didn't want to do it
>> in this patch, but I also don't see any candidates where that
>> would really make sense.
>>
>> The first patch should obviously go into 3.11, I'll let you
>> decide about the second. This one might actually be easier to
>> backport than the original one, but it'd still have to be done
>> carefully.
>
> I applied both patches.
> The lockdep issue vanished and i still can write emails :-)
>
> Thanks Johannes.
>
> Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
>
>
>>
>> johannes
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
