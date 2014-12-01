From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] test: bpf: expand DIV_KX to DIV_MOD_KX
Date: Mon, 1 Dec 2014 09:44:55 -0800
Message-ID: <CAMEtUuwPkvCP1=nc3V+grc_Gp-7JG8GZLpJtDEeMr5mR-T-w1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:60223 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbaLARo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 12:44:59 -0500
Received: by mail-qa0-f53.google.com with SMTP id bm13so7455189qab.26
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 09:44:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 1, 2014 at 2:12 AM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> Expand DIV_KX to use BPF_MOD operation in the
> DIV_KX bpf 'classic' test.
>
> CC: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Increases test coverage. Makes sense. Thanks
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

> ---
>  lib/test_bpf.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/lib/test_bpf.c b/lib/test_bpf.c
> index 3f167d2..80d78c5 100644
> --- a/lib/test_bpf.c
> +++ b/lib/test_bpf.c
> @@ -124,7 +124,7 @@ static struct bpf_test tests[] = {
>                 { { 0, 0xfffffffd } }
>         },
>         {
> -               "DIV_KX",
> +               "DIV_MOD_KX",
>                 .u.insns = {
>                         BPF_STMT(BPF_LD | BPF_IMM, 8),
>                         BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 2),
> @@ -134,12 +134,18 @@ static struct bpf_test tests[] = {
>                         BPF_STMT(BPF_MISC | BPF_TAX, 0),
>                         BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff),
>                         BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 0x70000000),
> +                       BPF_STMT(BPF_MISC | BPF_TAX, 0),
> +                       BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff),
> +                       BPF_STMT(BPF_ALU | BPF_MOD | BPF_X, 0),
> +                       BPF_STMT(BPF_MISC | BPF_TAX, 0),
> +                       BPF_STMT(BPF_LD | BPF_IMM, 0xffffffff),
> +                       BPF_STMT(BPF_ALU | BPF_MOD | BPF_K, 0x70000000),
>                         BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
>                         BPF_STMT(BPF_RET | BPF_A, 0)
>                 },
>                 CLASSIC | FLAG_NO_DATA,
>                 { },
> -               { { 0, 0x40000001 } }
> +               { { 0, 0x20000000 } }
>         },
>         {
>                 "AND_OR_LSH_K",
> --
> 1.7.10.4
>
