From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: tcpprobe display format for snd_nxt and snd_una
Date: Thu, 6 Apr 2017 17:45:31 -0400
Message-ID: <20170406174531.4fca96b0@plumbers-lap.home.lan>
References: <20170405194009.GH62406@strugglingcoder.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hiren panchasara <hiren@strugglingcoder.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33282 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752194AbdDFVpg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 17:45:36 -0400
Received: by mail-io0-f177.google.com with SMTP id t68so5114815iof.0
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 14:45:35 -0700 (PDT)
In-Reply-To: <20170405194009.GH62406@strugglingcoder.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Apr 2017 12:40:09 -0700
hiren panchasara <hiren@strugglingcoder.info> wrote:

> (New to linux and first-time poster so please guide me if needed.)
>  
> Upon using tcpprobe I realized that it prints snd_nxt and snd_una as hex
> which makes it harder to read and compare with tcpdump for example.
>  
> Not sure if that is intentional. If not, a simple patch like this would
> print them as decimals.
>  
> [PATCH] Display snd_nxt and snd_una as decimals for better
>  readability.
>  
> ---
>  net/ipv4/tcp_probe.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>  
> diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
> index f6c50af..a8e66c1 100644
> --- a/net/ipv4/tcp_probe.c
> +++ b/net/ipv4/tcp_probe.c
> @@ -191,7 +191,7 @@ static int tcpprobe_sprint(char *tbuf, int n)
>                 = ktime_to_timespec64(ktime_sub(p->tstamp, tcp_probe.start));
>  
>         return scnprintf(tbuf, n,
> -                       "%lu.%09lu %pISpc %pISpc %d %#x %#x %u %u %u %u %u\n",
> +                       "%lu.%09lu %pISpc %pISpc %d %u %u %u %u %u %u %u\n",
>                         (unsigned long)ts.tv_sec,
>                         (unsigned long)ts.tv_nsec,
>                         &p->src, &p->dst, p->length, p->snd_nxt, p->snd_una,
> --
>  
> Let me know if I am missing something obvious.

The output of tcpprobe is intended for consumption by programs.
Changing the output format would be considered a kernel ABI breakage which
is something Linux tries not to do. Therefore I would prefer it
not be changed. Sorry if this is inconvenient for you but breaking other
users scripts would be a bigger problem.

Also, your patch email is not formatted with subject [RFC] or [PATCH]
and is missing signed-off-by.
