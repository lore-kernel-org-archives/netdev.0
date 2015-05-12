From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][next] xfrm: optimise xfrm_policy_lookup_bytype
Date: Tue, 12 May 2015 16:25:07 +0800
Message-ID: <CAJFZqHywcxDx1vLTtTqVfVe6hoG1M8PYH4a-7HZ9XrFJPAM-Gw@mail.gmail.com>
References: <1431170257-18242-1-git-send-email-roy.qing.li@gmail.com>
	<20150511120616.GS8928@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36814 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbELIZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 04:25:08 -0400
Received: by qgeb100 with SMTP id b100so81428770qge.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 01:25:07 -0700 (PDT)
In-Reply-To: <20150511120616.GS8928@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 8:06 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> Please explain why it is unnecessary to continue with the
> loop here. In general a commit message should explain why
> this code is changed.
>
Ok, I will add


>> +                     break;
>
> priority is initialized with ~0U at the beginning of this function.
> What if someone has an inexact policy with priority ~0U configured?
> With your change, this policy will never match because we don't even
> try to search for it.

The original code can not handle this kind of policy whose priority is ~0U,
I will fix it when resubmit this patch.

1121         chain = &net->xfrm.policy_inexact[dir];
1122         hlist_for_each_entry(pol, chain, bydst) {
1123                 err = xfrm_policy_match(pol, fl, type, family, dir);
1124                 if (err) {
1125                         if (err == -ESRCH)
1126                                 continue;
1127                         else {
1128                                 ret = ERR_PTR(err);
1129                                 goto fail;
1130                         }
1131                 } else if (pol->priority < priority) {
1132                         ret = pol;
1133                         break;
1134                 }
1135         }
