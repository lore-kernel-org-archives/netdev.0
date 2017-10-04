From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying size
Date: Wed, 4 Oct 2017 09:59:05 -0400
Message-ID: <CAEfhGixoRM_wRy_e9reCGq69XUM1w-1kKGErCUty=gEB8DbzfA@mail.gmail.com>
References: <20171002164129.47986-1-kraigatgoog@gmail.com> <20171002164129.47986-2-kraigatgoog@gmail.com>
 <5082193f-0b59-bc40-290f-4ef3709a1d26@fb.com> <59D3A12B.7010101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <ast@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>,
        netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35022 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752103AbdJDN7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 09:59:07 -0400
Received: by mail-qk0-f193.google.com with SMTP id w63so6492655qkd.2
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 06:59:07 -0700 (PDT)
Received: from mail-qt0-f178.google.com (mail-qt0-f178.google.com. [209.85.216.178])
        by smtp.gmail.com with ESMTPSA id 6sm9907514qkh.8.2017.10.04.06.59.06
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 06:59:06 -0700 (PDT)
Received: by mail-qt0-f178.google.com with SMTP id o3so19316525qte.6
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 06:59:06 -0700 (PDT)
In-Reply-To: <59D3A12B.7010101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 10:39 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/03/2017 01:07 AM, Alexei Starovoitov wrote:
>>
>> On 10/2/17 9:41 AM, Craig Gallek wrote:
>>>
>>> +    /* Assume equally sized map definitions */
>>> +    map_def_sz = data->d_size / nr_maps;
>>> +    if (!data->d_size || (data->d_size % nr_maps) != 0) {
>>> +        pr_warning("unable to determine map definition size "
>>> +               "section %s, %d maps in %zd bytes\n",
>>> +               obj->path, nr_maps, data->d_size);
>>> +        return -EINVAL;
>>> +    }
>>
>>
>> this approach is not as flexible as done by samples/bpf/bpf_load.c
>> where it looks at every map independently by walking symtab,
>> but I guess it's ok.
>
>
> Regarding different map spec structs in a single prog: unless
> we have a good use case why we would need it (and I'm not aware
> of anything in particular), I would just go with a fixed size.
> I did kind of similar sanity checks in bpf_fetch_maps_end() in
> iproute2 loader as well.

Split vote?  I'm happy to try to make this work with varying sizes,
but I agree the usefulness seems low.  It would imply building map
sections with different definition structures and we would then need a
way to differentiate them.  If the goal is to allow for different map
definition structures, I don't think size alone is a sufficient
differentiator.
