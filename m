From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying
 size
Date: Mon, 2 Oct 2017 16:07:37 -0700
Message-ID: <5082193f-0b59-bc40-290f-4ef3709a1d26@fb.com>
References: <20171002164129.47986-1-kraigatgoog@gmail.com>
 <20171002164129.47986-2-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chonggang Li <chonggangli@google.com>, <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55958 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751104AbdJBXID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 19:08:03 -0400
In-Reply-To: <20171002164129.47986-2-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/17 9:41 AM, Craig Gallek wrote:
> +	/* Assume equally sized map definitions */
> +	map_def_sz = data->d_size / nr_maps;
> +	if (!data->d_size || (data->d_size % nr_maps) != 0) {
> +		pr_warning("unable to determine map definition size "
> +			   "section %s, %d maps in %zd bytes\n",
> +			   obj->path, nr_maps, data->d_size);
> +		return -EINVAL;
> +	}

this approach is not as flexible as done by samples/bpf/bpf_load.c
where it looks at every map independently by walking symtab,
but I guess it's ok.
I'd like to hear what Daniel and Jesper say,
since we really want to move to libbpf.a in samples/bpf/
and loader has to get to parity with the one in samples.
