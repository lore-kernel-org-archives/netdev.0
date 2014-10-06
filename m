From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 1/5] ipv6: minor fib6 cleanups like type safety,
 bool conversion, inline removal
Date: Mon, 6 Oct 2014 10:23:37 -0700
Message-ID: <CAHA+R7NR6xmjCN5JLirDYeT0it3CaHek-xGEL5R1YZsK+0qPmg@mail.gmail.com>
References: <cover.1412585162.git.hannes@stressinduktion.org>
	<d848631ba3331e6e18c3208b217d8ecf9b69d650.1412585163.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, hideaki@yoshifuji.org,
	kafai@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:60177 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbaJFRXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:23:39 -0400
Received: by mail-la0-f44.google.com with SMTP id gb8so4821234lab.17
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 10:23:37 -0700 (PDT)
In-Reply-To: <d848631ba3331e6e18c3208b217d8ecf9b69d650.1412585163.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 1:52 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> index cf485f9..f4e6b3e 100644
> --- a/include/net/ip6_fib.h
> +++ b/include/net/ip6_fib.h
> @@ -202,12 +202,22 @@ static inline void ip6_rt_put(struct rt6_info *rt)
>         dst_release(&rt->dst);
>  }
>
> +enum fib_walk_state_t {
> +#ifdef CONFIG_IPV6_SUBTREES
> +       FWS_S,
> +#endif
> +       FWS_L,
> +       FWS_R,
> +       FWS_C,
> +       FWS_U
> +};
> +
>  struct fib6_walker_t {

While you are on it, I think these *_t types don't actually need "_t",
they are not typedef's anyway. But this definitely could be a folllowup patch.
