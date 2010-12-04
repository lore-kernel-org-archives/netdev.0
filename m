From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 22:50:03 +0800
Message-ID: <AANLkTikeECFUf0xiug7G+nd5=Sw7p=4Msz6RQ2gdOBzs@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <1291472282.2159.8.camel@mojatatu>
 <1291473756.2159.31.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43556 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab0LDOuY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:50:24 -0500
Received: by fxm20 with SMTP id 20so3053887fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:50:23 -0800 (PST)
In-Reply-To: <1291473756.2159.31.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 4, 2010 at 10:42 PM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2010-12-04 at 09:18 -0500, jamal wrote:
>
>> I like the splice idea but this patch makes me twitch
>> a little. What test setup did you use to check it?
>
> Ok, here's one thing you changed which is important. We do:
>
> =A0-->XXX-->rq-->tq-->XXX-->
>
> rq is controlled by queue limit.
> We only load rq to tq if all of tq is empty. If it is not
> we dont move things over. Essentially this is a flow
> control scheme. We dont want many sources to be overwhelming
> us with packets and every time we grab a txqlen number of packets.
> For this reason:
> I would be comfortable if all you did was to add the splice
> after you skb_peek() - i think that would be a good improvement
> which is not bound to break anything else.
>

Maybe you misread my patch. tq is a stack variable in ri_tasklet, and
initialized all the time. ri_tasklet() won't exits until tq is
empty().


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
