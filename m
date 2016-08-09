From: Amir Vadai <amirva@gmail.com>
Subject: Re: [Patch net 5/5] net_sched: convert tcf_exts from list to flex_array
Date: Tue, 9 Aug 2016 11:03:50 +0300
Message-ID: <CAPcc5PhMHVSFoQVoF7u0Kcn0Cn=kLWB+Hr3bZT8f2rgk5pNfOw@mail.gmail.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com> <1470689209-17682-6-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: amir@vadai.me
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34234 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbcHIIEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 04:04:12 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so1532239wma.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 01:03:51 -0700 (PDT)
In-Reply-To: <1470689209-17682-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 8, 2016 at 11:46 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> As pointed out by Jamal, an action could be shared by
> multiple filters, so we can't use list to chain them
> any more after we get rid of the original tc_action.
> Instead, we could just save pointers to these actions
> in tcf_exts, since they are refcount'ed, so convert
> the list to a flex array.
>
> The ugly part is the action API still accepts list
> as a parameter, I just introduce a helper function to
> convert the flex array of pointers to a list.
>
> Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

[...]

> -#define tc_single_action(_exts) \
> -       (list_is_singular(&(_exts)->actions))
> +#define tc_no_actions(_exts)  (&(_exts)->nr_actions == 0)
> +#define tc_single_action(_exts) (&(_exts)->nr_actions == 1)

Should remove the '&' here.

Amir

[...]
