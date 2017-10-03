From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying
 size
Date: Tue, 03 Oct 2017 16:39:39 +0200
Message-ID: <59D3A12B.7010101@iogearbox.net>
References: <20171002164129.47986-1-kraigatgoog@gmail.com> <20171002164129.47986-2-kraigatgoog@gmail.com> <5082193f-0b59-bc40-290f-4ef3709a1d26@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        Craig Gallek <kraigatgoog@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49326 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdJCOjr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 10:39:47 -0400
In-Reply-To: <5082193f-0b59-bc40-290f-4ef3709a1d26@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2017 01:07 AM, Alexei Starovoitov wrote:
> On 10/2/17 9:41 AM, Craig Gallek wrote:
>> +    /* Assume equally sized map definitions */
>> +    map_def_sz = data->d_size / nr_maps;
>> +    if (!data->d_size || (data->d_size % nr_maps) != 0) {
>> +        pr_warning("unable to determine map definition size "
>> +               "section %s, %d maps in %zd bytes\n",
>> +               obj->path, nr_maps, data->d_size);
>> +        return -EINVAL;
>> +    }
>
> this approach is not as flexible as done by samples/bpf/bpf_load.c
> where it looks at every map independently by walking symtab,
> but I guess it's ok.

Regarding different map spec structs in a single prog: unless
we have a good use case why we would need it (and I'm not aware
of anything in particular), I would just go with a fixed size.
I did kind of similar sanity checks in bpf_fetch_maps_end() in
iproute2 loader as well.
