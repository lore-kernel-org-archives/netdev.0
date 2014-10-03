From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] ematch: Fix the matching of inverted containers (again).
Date: Fri, 03 Oct 2014 16:22:29 +0400
Message-ID: <542E9505.8010805@cogentembedded.com>
References: <20141003080600.GA13146@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?ISO-8859-2?Q?Ignacy_Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:55579 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbaJCMWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 08:22:33 -0400
Received: by mail-lb0-f179.google.com with SMTP id l4so873022lbv.38
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 05:22:31 -0700 (PDT)
In-Reply-To: <20141003080600.GA13146@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/3/2014 12:06 PM, Ignacy Gaw=EAdzki wrote:

> The result of a negated container has to be inverted before checking =
for
> early ending.

> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communication=
s.fr>
> ---
>   net/sched/ematch.c | 9 +++++----
>   1 file changed, 5 insertions(+), 4 deletions(-)

> diff --git a/net/sched/ematch.c b/net/sched/ematch.c
> index ad57f44..300ecf6 100644
> --- a/net/sched/ematch.c
> +++ b/net/sched/ematch.c
> @@ -526,11 +526,12 @@ pop_stack:
>   		match_idx =3D stack[--stackp];
>   		cur_match =3D tcf_em_get_match(tree, match_idx);
>
> -		if (tcf_em_early_end(cur_match, res)) {
> -			if (tcf_em_is_inverted(cur_match))
> -				res =3D !res;
> +		if (tcf_em_is_inverted(cur_match))
> +			res =3D !res;
> +
> +		if (tcf_em_early_end(cur_match, res))
>   			goto pop_stack;
> -		} else {
> +		else {
>   			match_idx++;
>   			goto proceed;
>   		}

    The kernel style dictates that an *if* statement should have {} in =
all its=20
arms, if it has {} in at least one of the arms.

WBR, Sergei
