From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net v2] net: ipv6: allow explicitly choosing optimistic addresses
Date: Mon, 2 Feb 2015 15:20:45 +0900
Message-ID: <CAAedzxr0kv4QKHdHJK5QvvZhgb+1pYjxGua2iuMWWEWE2fwOAg@mail.gmail.com>
References: <1422446619-9502-1-git-send-email-ek@google.com> <CAKD1Yr2LJT+rYwbKQMvMQFtSDTwQAHk5k__m22J=kx8eKxj1JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:44687 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073AbbBBGVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 01:21:07 -0500
Received: by mail-qc0-f178.google.com with SMTP id b13so28853540qcw.9
        for <netdev@vger.kernel.org>; Sun, 01 Feb 2015 22:21:05 -0800 (PST)
In-Reply-To: <CAKD1Yr2LJT+rYwbKQMvMQFtSDTwQAHk5k__m22J=kx8eKxj1JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 2:25 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> On Wed, Jan 28, 2015 at 9:03 PM, Erik Kline <ek@google.com> wrote:
>>                 if (ipv6_addr_equal(&ifp->addr, addr) &&
>> -                   !(ifp->flags&IFA_F_TENTATIVE) &&
>> +                   (!(ifp->flags&banned_flags) ||
>> +                    ifp->flags&IFA_F_OPTIMISTIC&~banned_flags) &&
>
> Is this if statement correct?
>
> The intent here is "if ifp has IFA_F_OPTIMISTIC set, then
> IFA_F_TENTATIVE is allowed, even if the caller explicitly banned
> IFA_F_TENTATIVE", right? Not "if ifp has IFA_F_OPTIMISTIC set, then
> any flags are allowed, even ones explicitly baned by the caller". For
> example, suppose that:
>
>     banned_flags = IFA_F_SECONDARY
>     ifp->flags = IFA_F_SECONDARY | IFA_F_OPTIMISTIC
>
> In that case, won't the if statement match ifp, even though it
> contains a flag that is explicitly banned?

Yep, true.  It works for all existing inputs, but is not generally
future-proof.  :(

I have a rewrite that explicitly defines the circumstances under which
optimistic would be considered ok in this check.  If there are changes
in that definition in the future that one clause will need to be
updated accordingly.

Patch coming in minutes.
