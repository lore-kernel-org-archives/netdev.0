From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute PATCH 51/51] lib/bpf: Check return value of write()
Date: Mon, 14 Aug 2017 11:17:39 +0200
Message-ID: <59916AB3.1010001@iogearbox.net>
References: <20170812120510.28750-1-phil@nwl.cc> <20170812120510.28750-52-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38165 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752346AbdHNJRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 05:17:43 -0400
In-Reply-To: <20170812120510.28750-52-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2017 02:05 PM, Phil Sutter wrote:
> This is merely to silence the compiler warning. If write to stderr
> failed, assume that printing an error message will fail as well so don't
> even try.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>   lib/bpf.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/lib/bpf.c b/lib/bpf.c
> index 1dcb261dc915f..825e071cea572 100644
> --- a/lib/bpf.c
> +++ b/lib/bpf.c
> @@ -591,7 +591,8 @@ int bpf_trace_pipe(void)
>
>   		ret = read(fd, buff, sizeof(buff) - 1);
>   		if (ret > 0) {
> -			write(2, buff, ret);
> +			if (write(STDERR_FILENO, buff, ret) != ret)
> +				return -1;

Quite unlikely to fail, but we should probably bark loudly
here instead of just returning -1. Perhaps assert() would
suit better.

>   			fflush(stderr);
>   		}
>   	}
>
