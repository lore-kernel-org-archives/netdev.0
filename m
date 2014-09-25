From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ematch: Fix matching of inverted containers.
Date: Thu, 25 Sep 2014 14:08:24 -0700
Message-ID: <CAHA+R7N8-4LwaOqv8NHQ=p5-wU6ya9ya3GLsOkkBjQmhBQ94yA@mail.gmail.com>
References: <20140924163839.GA6925@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>
To: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:36556 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbaIYVI0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 17:08:26 -0400
Received: by mail-lb0-f173.google.com with SMTP id 10so11544729lbg.4
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 14:08:24 -0700 (PDT)
In-Reply-To: <20140924163839.GA6925@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Cc'ing Thomas)

On Wed, Sep 24, 2014 at 9:38 AM, Ignacy Gaw=C4=99dzki
<ignacy.gawedzki@green-communications.fr> wrote:
> Negated expressions and sub-expressions need to have their flags chec=
ked for
> TCF_EM_INVERT and their result negated accordingly.
>
> Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communicat=
ions.fr>
> ---
>  net/sched/ematch.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/sched/ematch.c b/net/sched/ematch.c
> index 3a633de..ad57f44 100644
> --- a/net/sched/ematch.c
> +++ b/net/sched/ematch.c
> @@ -526,9 +526,11 @@ pop_stack:
>                 match_idx =3D stack[--stackp];
>                 cur_match =3D tcf_em_get_match(tree, match_idx);
>
> -               if (tcf_em_early_end(cur_match, res))
> +               if (tcf_em_early_end(cur_match, res)) {
> +                       if (tcf_em_is_inverted(cur_match))
> +                               res =3D !res;
>                         goto pop_stack;
> -               else {
> +               } else {
>                         match_idx++;
>                         goto proceed;
>                 }
> --
> 1.9.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
