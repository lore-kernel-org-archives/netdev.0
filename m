From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying size
Date: Wed, 4 Oct 2017 09:58:41 -0400
Message-ID: <CAEfhGixa=uFJJose-mJFGJzPCZpHChUijqGwWRTqkgsswrG3dg@mail.gmail.com>
References: <20171002164129.47986-1-kraigatgoog@gmail.com> <20171002164129.47986-2-kraigatgoog@gmail.com>
 <20171003161151.039979f4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>,
        netdev <netdev@vger.kernel.org>,
        Eric Leblond <eric.leblond@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33293 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752172AbdJDN6p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 09:58:45 -0400
Received: by mail-qk0-f193.google.com with SMTP id z12so4899683qkb.0
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 06:58:45 -0700 (PDT)
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com. [209.85.220.170])
        by smtp.gmail.com with ESMTPSA id b32sm2137804qta.45.2017.10.04.06.58.43
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 06:58:44 -0700 (PDT)
Received: by mail-qk0-f170.google.com with SMTP id d67so8108126qkg.5
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 06:58:43 -0700 (PDT)
In-Reply-To: <20171003161151.039979f4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 10:11 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Mon,  2 Oct 2017 12:41:28 -0400
> Craig Gallek <kraigatgoog@gmail.com> wrote:
>
>> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
>> index 4f402dcdf372..28b300868ad7 100644
>> --- a/tools/lib/bpf/libbpf.c
>> +++ b/tools/lib/bpf/libbpf.c
>> @@ -580,7 +580,7 @@ bpf_object__init_kversion(struct bpf_object *obj,
>>  }
>>
>>  static int
>> -bpf_object__validate_maps(struct bpf_object *obj)
>> +bpf_object__validate_maps(struct bpf_object *obj, int map_def_sz)
>>  {
>>       int i;
>>
>> @@ -595,9 +595,11 @@ bpf_object__validate_maps(struct bpf_object *obj)
>>               const struct bpf_map *a = &obj->maps[i - 1];
>>               const struct bpf_map *b = &obj->maps[i];
>>
>> -             if (b->offset - a->offset < sizeof(struct bpf_map_def)) {
>> -                     pr_warning("corrupted map section in %s: map \"%s\" too small\n",
>> -                                obj->path, a->name);
>> +             if (b->offset - a->offset < map_def_sz) {
>> +                     pr_warning("corrupted map section in %s: map \"%s\" too small "
>> +                                "(%zd vs %d)\n",
>> +                                obj->path, a->name, b->offset - a->offset,
>> +                                map_def_sz);
>>                       return -EINVAL;
>
> Hmm... one more comment.  You have just coded handling of ELF
> map_def_sz which are smaller in a safe manor, but here this case will
> get rejected (in bpf_object__validate_maps).  That cannot be the right
> intend?

I think you are right, but my test program didn't catch this...
Perhaps an off-by-one (I only used slightly smaller map_def sizes).  I
suppose this entire function is unnecessary now.  Even the old version
wouldn't catch the case where the last offset was out of bounds?

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
