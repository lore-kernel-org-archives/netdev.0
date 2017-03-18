From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: convert sk_filter.refcnt from atomic_t to refcount_t
Date: Sat, 18 Mar 2017 17:33:22 +0300
Message-ID: <a19263a2-141b-22ad-4300-0ffe54cae8d6@cogentembedded.com>
References: <1489841889-27601-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        peterz@infradead.org, keescook@chromium.org,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: Elena Reshetova <elena.reshetova@intel.com>, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34338 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751645AbdCRQRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 12:17:35 -0400
Received: by mail-lf0-f54.google.com with SMTP id z15so42825515lfd.1
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 09:17:34 -0700 (PDT)
In-Reply-To: <1489841889-27601-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/18/2017 3:58 PM, Elena Reshetova wrote:

> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
>
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>
[...]
> diff --git a/net/core/filter.c b/net/core/filter.c
> index ebaeaf2..62267e2 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
[...]
> @@ -1179,12 +1179,13 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
>  		return -ENOMEM;
>
>  	fp->prog = prog;
> -	atomic_set(&fp->refcnt, 0);
> +	refcount_set(&fp->refcnt, 1);
>
>  	if (!sk_filter_charge(sk, fp)) {
>  		kfree(fp);
>  		return -ENOMEM;
>  	}
> +	refcount_set(&fp->refcnt, 1);

    Why do it twice?

[...]

MBR, Sergei
