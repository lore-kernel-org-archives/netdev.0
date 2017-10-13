From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: fix a compile warning in act_ife
Date: Fri, 13 Oct 2017 16:16:51 -0400
Message-ID: <858tgex0p8.fsf@mojatatu.com>
References: <20171013195813.25321-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:50190 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdJMUQ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 16:16:57 -0400
Received: by mail-it0-f68.google.com with SMTP id 72so12664690itl.5
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 13:16:57 -0700 (PDT)
In-Reply-To: <20171013195813.25321-1-xiyou.wangcong@gmail.com> (Cong Wang's
        message of "Fri, 13 Oct 2017 12:58:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> Apparently ife_meta_id2name() is only called when
> CONFIG_MODULES is defined.
>
> This fixes:
>
> net/sched/act_ife.c:251:20: warning: =E2=80=98ife_meta_id2name=E2=80=99 d=
efined but not used [-Wunused-function]
>  static const char *ife_meta_id2name(u32 metaid)
>                     ^~~~~~~~~~~~~~~~

Fair enough, thanks Cong!

> Fixes: d3f24ba895f0 ("net sched actions: fix module auto-loading")
> Cc: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/act_ife.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
> index 252ee7d8c731..3007cb1310ea 100644
> --- a/net/sched/act_ife.c
> +++ b/net/sched/act_ife.c
> @@ -248,6 +248,7 @@ static int ife_validate_metatype(struct tcf_meta_ops =
*ops, void *val, int len)
>  	return ret;
>  }
>=20=20
> +#ifdef CONFIG_MODULES
>  static const char *ife_meta_id2name(u32 metaid)
>  {
>  	switch (metaid) {
> @@ -261,6 +262,7 @@ static const char *ife_meta_id2name(u32 metaid)
>  		return "unknown";
>  	}
>  }
> +#endif
>=20=20
>  /* called when adding new meta information
>   * under ife->tcf_lock for existing action
