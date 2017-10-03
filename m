From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying
 size
Date: Tue, 3 Oct 2017 16:11:51 +0200
Message-ID: <20171003161151.039979f4@redhat.com>
References: <20171002164129.47986-1-kraigatgoog@gmail.com>
        <20171002164129.47986-2-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org,
        brouer@redhat.com, Eric Leblond <eric.leblond@gmail.com>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40498 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751557AbdJCOL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 10:11:58 -0400
In-Reply-To: <20171002164129.47986-2-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  2 Oct 2017 12:41:28 -0400
Craig Gallek <kraigatgoog@gmail.com> wrote:

> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 4f402dcdf372..28b300868ad7 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -580,7 +580,7 @@ bpf_object__init_kversion(struct bpf_object *obj,
>  }
>  
>  static int
> -bpf_object__validate_maps(struct bpf_object *obj)
> +bpf_object__validate_maps(struct bpf_object *obj, int map_def_sz)
>  {
>  	int i;
>  
> @@ -595,9 +595,11 @@ bpf_object__validate_maps(struct bpf_object *obj)
>  		const struct bpf_map *a = &obj->maps[i - 1];
>  		const struct bpf_map *b = &obj->maps[i];
>  
> -		if (b->offset - a->offset < sizeof(struct bpf_map_def)) {
> -			pr_warning("corrupted map section in %s: map \"%s\" too small\n",
> -				   obj->path, a->name);
> +		if (b->offset - a->offset < map_def_sz) {
> +			pr_warning("corrupted map section in %s: map \"%s\" too small "
> +				   "(%zd vs %d)\n",
> +				   obj->path, a->name, b->offset - a->offset,
> +				   map_def_sz);
>  			return -EINVAL;

Hmm... one more comment.  You have just coded handling of ELF
map_def_sz which are smaller in a safe manor, but here this case will
get rejected (in bpf_object__validate_maps).  That cannot be the right
intend?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
