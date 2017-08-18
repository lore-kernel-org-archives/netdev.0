From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix a return in sockmap_get_from_fd()
Date: Fri, 18 Aug 2017 00:40:45 -0700
Message-ID: <599699FD.5000002@gmail.com>
References: <20170818071210.wyq37kura6wz6bx6@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33475 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdHRHk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 03:40:58 -0400
In-Reply-To: <20170818071210.wyq37kura6wz6bx6@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2017 12:27 AM, Dan Carpenter wrote:
> "map" is a valid pointer.  We wanted to return "err" instead.  Also
> let's return a zero literal at the end.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index d2f2bdf71ffa..b8cb1b3c9bfb 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c

Thanks, just a note though the sockmap attach call can not fail so
this branch is effectively never used. We could just remove the
branch but having an unchecked 'err' code seems fragile if we ever
do find a reason to fail in the attach path.

Acked-by: John Fastabend <john.fastabend@gmail.com>

> @@ -1125,11 +1125,11 @@ static int sockmap_get_from_fd(const union bpf_attr *attr, int ptype)
>  		fdput(f);
>  		bpf_prog_put(prog1);
>  		bpf_prog_put(prog2);
> -		return PTR_ERR(map);
> +		return err;
>  	}
>  
>  	fdput(f);
> -	return err;
> +	return 0;
>  }
>  
>  static int bpf_prog_attach(const union bpf_attr *attr)
> 
