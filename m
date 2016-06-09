From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH] openvswitch: Add packet truncation support.
Date: Thu, 9 Jun 2016 15:04:49 -0700
Message-ID: <CAOrHB_Ds+XubYetkPcqJa3hUPgb=9uRqYeVHco4324uuoimWdA@mail.gmail.com>
References: <1465435105-21777-1-git-send-email-u9012063@gmail.com>
 <CAOrHB_CNZ2_JCt7RCaMQehZvYxZO-3wL00krbPX-iT1z3iAu=w@mail.gmail.com> <CALDO+SZ-Zzc96VQPHsKoDaSsQg6ZFmQWDaXhGLwny4FD2bqcSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:55800 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932314AbcFIWEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 18:04:55 -0400
Received: from mfilter30-d.gandi.net (mfilter30-d.gandi.net [217.70.178.161])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id 8E8A8C5A46
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 00:04:52 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter30-d.gandi.net (mfilter30-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id 14JB66rzJVGb for <netdev@vger.kernel.org>;
	Fri, 10 Jun 2016 00:04:51 +0200 (CEST)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 1F98EC5A4F
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 00:04:50 +0200 (CEST)
Received: by mail-io0-f177.google.com with SMTP id o127so4397728iod.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 15:04:50 -0700 (PDT)
In-Reply-To: <CALDO+SZ-Zzc96VQPHsKoDaSsQg6ZFmQWDaXhGLwny4FD2bqcSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 9, 2016 at 1:02 PM, William Tu <u9012063@gmail.com> wrote:
>
>> >
>> >         /* The only known usage of sample action is having a single
>> > user-space
>> > +        * action, or having a truncate action followed by a single
>> > user-space
>> >          * action. Treat this usage as a special case.
>> >          * The output_userspace() should clone the skb to be sent to the
>> >          * user space. This skb will be consumed by its caller.
>> >          */
>> > +       if (unlikely(nla_type(a) == OVS_ACTION_ATTR_TRUNC)) {
>> > +               struct ovs_action_trunc *trunc = nla_data(a);
>> > +
>> > +               OVS_CB(skb)->cutlen = skb->len > trunc->max_len ?
>> > +                                               skb->len -
>> > trunc->max_len : 0;
>>
>> There is no need to initialize the cutlen to zero if max-len is
>> greater then skb len. it should be already zero.
>>
>> > +               a = nla_next(a, &rem);
>> > +       }
>> > +
>> There cutlen is set in skb cb, but next action could be other than
>> userspace, in that case cutlen is leaked to remain action list.
>>
>
> Thanks! I will fix it.
>
> Thinking about cutlen to the remaining action list, should we consider the
> truncate and output in sample action? ex:  "sample(truncate(64), output:2)"
>
The patch already covers it. sample calls add_deferred_actions() which
would execute nested set of actions later on.
