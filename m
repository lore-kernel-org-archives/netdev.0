From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Mon, 16 Jan 2017 10:51:29 +0100
Message-ID: <20170116095129.GB1804@nanopsycho.orion>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <20170108171251.GF1971@nanopsycho>
 <040c6876-a323-0a35-229f-46bc33b6de11@mellanox.com>
 <587BC894.3080909@gmail.com>
 <11bcf09a-0144-fd7f-369b-771962475c5e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34554 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdAPJvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 04:51:33 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so29357889wmi.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 01:51:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <11bcf09a-0144-fd7f-369b-771962475c5e@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 16, 2017 at 08:54:18AM CET, paulb@mellanox.com wrote:
>
>
>On 15/01/2017 21:08, John Fastabend wrote:
>> On 17-01-15 09:36 AM, Paul Blakey wrote:
>> > 
>> > 
>> > On 08/01/2017 19:12, Jiri Pirko wrote:
>> > > Mon, Jan 02, 2017 at 03:59:49PM CET, jhs@mojatatu.com wrote:
>> > > > 
>> > > > We have been using a cookie as well for actions (which we have been
>> > > > using but have been too lazy to submit so far). I am going to port
>> > > > it over to the newer kernels and post it.
>> > > 
>> > > Hard to deal with something we can't look at :)
>> > > 
>> > > 
>> > > > In our case that is intended to be opaque to the kernel i.e kernel
>> > > > never inteprets it; in that case it is similar to the kernel
>> > > > FIB protocol field.
>> > > 
>> > > In case of this patch, kernel also never interprets it. What makes you
>> > > think otherwise. Bot kernel, it is always a binary blob.
>> > > 
>> > > 
>> > > > 
>> > > > In your case - could this cookie have been a class/flowid
>> > > > (a 32 bit)?
>> > > > And would it not make more sense for it the cookie to be
>> > > > generic to all classifiers? i.e why is it specific to flower?
>> > > 
>> > > Correct, makes sense to have it generic for all cls and perhaps also
>> > > acts.
>> > > 
>> > > 
>> > 
>> > Hi all,
>> > I've started implementing a general cookie for all classifiers,
>> > I added the cookie on tcf_proto struct but then I realized that it won't work as
>> > I want. What I want is cookie per internal element (those that are identified by
>> > handles), which we can have many per one tcf_proto:
>> > 
>> > tc filter add dev <DEV> parent ffff: prio 1 cookie 0x123 basic action drop
>> > tc filter add dev <DEV> parent ffff: prio 1 cookie 0x456 "port6" basic action drop
>> > tc filter add dev <DEV> parent ffff: prio 1 cookie 0x777 basic action drop
>> > 
>> > So there is three options to do that:
>> > 1) Implement it in each classifier, using some generic function. (kinda like
>> > stats, where classifiler_dump() calls tcf_exts_dump_stats())
>> > 2) Have a global hash table for cookies [prio,handle]->[cookie]
>> > 3) Have it on flower only for now :)
>> > 
>> > With the first one we will have to change each classifier (or leave it
>> > unsupported as default).
>> > Second is less code to change (instead of changing each classifier), but might
>> > be slower. I'm afraid how it will affect dumping several filters.
>> > Third is this patch.
>> > 
>> > Thanks,
>> > Paul.
>> 
>> Avoid (2) it creates way more problems than its worth like is it locked/not
>> locked, how is it synced, collisions, etc. Seems way overkill.

+1


>> 
>> I like the generic functionality of (1) but unless we see this pop up in
>> different filters I wouldn't require it for now. If you just do it in flower
>> (option 3) when its added to another classifier we can generalize it. As a
>> middle ground creating nice helper routines as needed goes a long way.
>> 
>> .John
>> 
>
>Hi all,
>So is everyone ok with leaving the commit as is, only adding user data
>to flower for now?

I think we should do it in a generic way, for every classifier, right
away. Same as Jamal is doing for actions. I think that first we should
get Jamal's patch merged and then do the same for classifiers.
