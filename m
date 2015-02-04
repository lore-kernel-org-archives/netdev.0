From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net v3] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 4 Feb 2015 19:38:11 +0900
Message-ID: <CAAedzxoF2gJit1e05UJSOWX2RJwbA1PSbdABK3zgta-XtajJyw@mail.gmail.com>
References: <1422859156-30691-1-git-send-email-ek@google.com> <CAKD1Yr0k44kwwtfWN-t9C1f7WKT0o=yimPwbfLtBnnvUvXrm=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:46421 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965440AbbBDKid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 05:38:33 -0500
Received: by mail-qa0-f48.google.com with SMTP id v8so476640qal.7
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 02:38:32 -0800 (PST)
In-Reply-To: <CAKD1Yr0k44kwwtfWN-t9C1f7WKT0o=yimPwbfLtBnnvUvXrm=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +               bool optimistic_ok = (ifp->flags & IFA_F_OPTIMISTIC) &&
>> +                                    (banned_flags == IFA_F_TENTATIVE);
>
> Not sure if this can happen in any real use case, but I think that
> technically this is incorrect if banned_flags contains both
> IFA_F_TENTATIVE and other flags that aren't IFA_F_OPTIMISTIC. For
> example, suppose banned_flags = IFA_F_TENTATIVE | IFA_F_PERMANENT. In
> that case, I think the code would reject an address with
> IFA_F_TENTATIVE | IFA_F_OPTIMISTIC. You might be able to fix that

Exactly what I was trying to address, but I tried to choose the
uber-conservative option and require folks to explicitly list when
optimistic should be treated distinctly from tentative.

That of course, wasn't really future-proof and someone might not know
or simply forget to update this check as needed.

>                ifp_flags = ifp->flags;
>                if (ifp_flags & IFA_F_OPTIMISTIC) ifp_flags &= ~IFA_F_TENTATIVE;

I think this is cleaner.  I've got a version now that incorporates this.

One more thing I just noticed, though: if the interface and the
address matches the supplied arguments but we don't like the flags we
keep on processing all other addresses on that interface I think.  Is
that right?  (Easy to fix in a follow on patch.)
