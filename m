From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] libbpf: parse maps sections of varying size
Date: Wed, 4 Oct 2017 09:58:17 -0400
Message-ID: <CAEfhGizpYSn=sQ+XvuTUzTZDqLLMg8mODE18HgM119sq3hyhnw@mail.gmail.com>
References: <20171002164129.47986-1-kraigatgoog@gmail.com> <20171002164129.47986-2-kraigatgoog@gmail.com>
 <20171003160348.1d84548d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Chonggang Li <chonggangli@google.com>,
        netdev <netdev@vger.kernel.org>, Eric Leblond <eric@regit.org>,
        "Wangnan (F)" <wangnan0@huawei.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:54814 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752065AbdJDN6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 09:58:21 -0400
Received: by mail-qt0-f193.google.com with SMTP id i13so19284551qtc.11
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 06:58:20 -0700 (PDT)
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com. [209.85.220.170])
        by smtp.gmail.com with ESMTPSA id c52sm2858834qtc.24.2017.10.04.06.58.18
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 06:58:19 -0700 (PDT)
Received: by mail-qk0-f170.google.com with SMTP id n5so9258353qke.11
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 06:58:18 -0700 (PDT)
In-Reply-To: <20171003160348.1d84548d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 10:03 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
>
> First of all, thank you Craig for working on this.  As Alexei says, we
> need to improve tools/lib/bpf/libbpf and move towards converting users
> of bpf_load.c to this lib instead.
>
> Comments inlined below.
>
>> +                     obj->maps[map_idx].def = *def;
>
> I'm not too happy/comfortable with this way of copying the memory of
> "def" (the type-cased struct bpf_map_def).  I guess it works, and is
> part of the C-standard(?).

I believe this is a C++-ism.  I'm not sure if it was pulled into the
C99 standard or if it's just a gcc 'feature' now.  I kept it because
it was in the initial code, but I'm happy to do an explicit copy for
v3 if that looks better.
