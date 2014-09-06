From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/3] net: bpf: be friendly to kmemcheck
Date: Sat, 6 Sep 2014 09:09:51 -0700
Message-ID: <CAMEtUuz5ec8=-x9QO+jjSENz+rKVdv0Avhupi4snSgUboSaKUA@mail.gmail.com>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
	<1409996567-2170-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Mikulas Patocka <mpatocka@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:58072 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbaIFQJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 12:09:53 -0400
Received: by mail-we0-f173.google.com with SMTP id t60so13025233wes.4
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 09:09:52 -0700 (PDT)
In-Reply-To: <1409996567-2170-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 6, 2014 at 2:42 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Reported by Mikulas Patocka, kmemcheck currently barks out a
> false positive since we don't have special kmemcheck annotation
> for bitfields used in bpf_prog structure.
>
> We currently have jited:1, len:31 and thus when accessing len
> while CONFIG_KMEMCHECK enabled, kmemcheck throws a warning that
> we're reading uninitialized memory.
>
> As we don't need the whole bit universe for pages member, we
> can just split it to u16 and use a bool flag for jited instead
> of a bitfield.
>
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  arch/arm/net/bpf_jit_32.c       | 2 +-
>  arch/mips/net/bpf_jit.c         | 2 +-
>  arch/powerpc/net/bpf_jit_comp.c | 2 +-
>  arch/s390/net/bpf_jit_comp.c    | 2 +-
>  arch/sparc/net/bpf_jit_comp.c   | 2 +-
>  arch/x86/net/bpf_jit_comp.c     | 2 +-
>  include/linux/filter.h          | 6 +++---
>  net/core/filter.c               | 2 +-
>  8 files changed, 10 insertions(+), 10 deletions(-)

This one also looks good. Thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
