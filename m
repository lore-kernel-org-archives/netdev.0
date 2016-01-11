From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 6/9] bpf: arraymap: introduce BPF_MAP_TYPE_ARRAY_PERCPU
Date: Mon, 11 Jan 2016 11:14:34 -0800
Message-ID: <20160111191433.GC26495@ast-mbp.thefacebook.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
 <1452527821-12276-7-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36330 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbcAKTOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 14:14:37 -0500
Content-Disposition: inline
In-Reply-To: <1452527821-12276-7-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 11:56:58PM +0800, Ming Lei wrote:
> This patch introduces percpu array map so that expensive
> atomic operations can be avoided in eBPF prog in case of
> ARRAY map.
> 
> PERCPU MAP uses the percpu version of update/lookup element
> helpers and callbacks to access element in the map, and
> the previous update/lookup element helpers and callbacks
> don't work at the same time.
> 
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

useful stuff!

> +	if (percpu) {
> +		if (alloc_percpu_array(array, attr->max_entries,
> +				       attr->value_size)) {
> +			kvfree(array);
> +			return ERR_PTR(-ENOMEM);
> +		}
> +		array->map.pages = round_up(attr->max_entries *
> +				attr->value_size * num_possible_cpus(),
> +				PAGE_SIZE) >> PAGE_SHIFT;

I think it would be more accurate to add it to array_size instead of
doing page rounding here.

> -	array->map.pages = round_up(array_size, PAGE_SIZE) >> PAGE_SHIFT;
> +	array->map.pages += round_up(array_size, PAGE_SIZE) >> PAGE_SHIFT;

and this line wouldn't need to change...
