From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 5/5] bpf: split state from prandom_u32() and
 consolidate {c,e}BPF prngs
Date: Wed, 7 Oct 2015 09:38:28 -0700
Message-ID: <56154A84.5020206@plumgrid.com>
References: <cover.1444224502.git.daniel@iogearbox.net>
 <2b3b623837d040c99186d76966c3524f17057745.1444224502.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	Chema Gonzalez <chema@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33226 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995AbbJGQi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:38:28 -0400
Received: by pacex6 with SMTP id ex6so26119889pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:38:27 -0700 (PDT)
In-Reply-To: <2b3b623837d040c99186d76966c3524f17057745.1444224502.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 6:43 AM, Daniel Borkmann wrote:
> +void bpf_user_rnd_init_once(void)
> +{
> +	prandom_init_once(&bpf_user_rnd_state);
> +}

here the helper is definitely needed, since it's called from two
places and we must make sure that prandom_init_once doesn't
duplicate its static_key in two places.
Probably makes sense to add a comment to do_once api that

do_once(func, arg);
do_once(func, arg);

is not equal to

void my_helper(void) { do_once(func, arg); }
my_helper();
my_helper();

For this patch:
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
