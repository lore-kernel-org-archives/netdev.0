From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 -next 1/5] {f,m}_bpf: make tail calls working
Date: Thu, 26 Nov 2015 16:10:44 +0300
Message-ID: <565704D4.8070201@cogentembedded.com>
References: <cover.1448541097.git.daniel@iogearbox.net>
 <88d074dcdf1469ea381e1d732852cc87fb1aba2c.1448541097.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34857 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbbKZNKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 08:10:48 -0500
Received: by lfdl133 with SMTP id l133so96850219lfd.2
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 05:10:47 -0800 (PST)
In-Reply-To: <88d074dcdf1469ea381e1d732852cc87fb1aba2c.1448541097.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/26/2015 3:58 PM, Daniel Borkmann wrote:

> Now that we have the possibility of sharing maps, it's time we get the
> ELF loader fully working with regards to tail calls. Since program array
> maps are pinned, we can keep them finally alive. I've noticed two bugs
> that are being fixed in bpf_fill_prog_arrays() with this patch. Example
> code comes as follow-up.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---
>   tc/tc_bpf.c | 31 +++++++++++++++++++++++--------
>   1 file changed, 23 insertions(+), 8 deletions(-)
>
> diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
> index bc7bc9f..73a0f41 100644
> --- a/tc/tc_bpf.c
> +++ b/tc/tc_bpf.c
> @@ -1139,11 +1139,26 @@ static int bpf_fetch_prog_sec(struct bpf_elf_ctx *ctx, const char *section)
>   	return ret;
>   }
>
> +static int bpf_find_map_by_id(struct bpf_elf_ctx *ctx, uint32_t id)
> +{
> +	int i, ret = -1;
> +
> +	for (i = 0; i < ARRAY_SIZE(ctx->map_fds); i++) {
> +		if (ctx->map_fds[i] && ctx->maps[i].id == id &&
> +		    ctx->maps[i].type == BPF_MAP_TYPE_PROG_ARRAY) {
> +			ret = i;
> +			break;

    Isn't just *return* i; simpler? That way, you don't need 'ret' at all.

> +		}
> +	}
> +
> +	return ret;
> +}
> +
[...]

MBR, Sergei
