From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 03/10] 9pnet: refactor struct p9_fcall alloc code
Date: Tue, 02 Jul 2013 20:40:58 +0400
Message-ID: <51D3029A.8050100@cogentembedded.com>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net> <1372770684-25573-4-git-send-email-simon.derr@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ericvh@gmail.com
To: Simon Derr <simon.derr@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:58739 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530Ab3GBQlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 12:41:06 -0400
Received: by mail-lb0-f178.google.com with SMTP id y6so3486341lbh.23
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 09:41:04 -0700 (PDT)
In-Reply-To: <1372770684-25573-4-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-07-2013 17:11, Simon Derr wrote:

> Signed-off-by: Simon Derr <simon.derr@bull.net>
> ---
>   net/9p/client.c |   35 ++++++++++++++++++-----------------
>   1 files changed, 18 insertions(+), 17 deletions(-)

> diff --git a/net/9p/client.c b/net/9p/client.c
> index 47cd7d0..44691b9 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -204,6 +204,17 @@ free_and_return:
>   	return ret;
>   }
>
> +struct p9_fcall *p9_fcall_alloc(int alloc_msize)
> +{
> +	struct p9_fcall *fc;

    Empty line wouldn't hurt here, after declaration.

> +	fc = kmalloc(sizeof(struct p9_fcall) + alloc_msize, GFP_NOFS);
> +	if (!fc)
> +		return NULL;
> +	fc->capacity = alloc_msize;
> +	fc->sdata = (char *) fc + sizeof(struct p9_fcall);
> +	return fc;
> +}
> +
[...]

WBR, Sergei
