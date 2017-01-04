From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/6] Prepare BPF for VLAN_TAG_PRESENT cleanup
Date: Wed, 04 Jan 2017 21:11:57 +0100
Message-ID: <586D570D.9060800@iogearbox.net>
References: <cover.1483492355.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: alexei.starovoitov@gmail.com
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60341 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762100AbdADUL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 15:11:59 -0500
In-Reply-To: <cover.1483492355.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 02:18 AM, Michał Mirosław wrote:
> Those patches prepare BPF ant its JITs for removal of VLAN_TAG_PRESENT.
> The set depends on "Preparation for VLAN_TAG_PRESENT cleanup" patchset.
>
> The series is supposed to be bisect-friendly and that requires temporary
> insertion of #define VLAN_TAG_PRESENT in BPF code to be able to split
> JIT changes per architecture.
>
> Michał Mirosław (6):
>    net/skbuff: add macros for VLAN_PRESENT bit
>    net/bpf_jit: ARM: split VLAN_PRESENT bit handling from VLAN_TCI
>    net/bpf_jit: MIPS: split VLAN_PRESENT bit handling from VLAN_TCI
>    net/bpf_jit: PPC: split VLAN_PRESENT bit handling from VLAN_TCI
>    net/bpf_jit: SPARC: split VLAN_PRESENT bit handling from VLAN_TCI
>    net/bpf: split VLAN_PRESENT bit handling from VLAN_TCI

Please add a proper changelog to all the individual patches, right now
they have none. Also, how was this runtime tested? Did you run BPF selftest
suite with them? Seems like they weren't even compile tested properly
given the kbuild bot barking on sparc ...

>   arch/arm/net/bpf_jit_32.c       | 16 ++++++++++------
>   arch/mips/net/bpf_jit.c         | 18 ++++++++++--------
>   arch/powerpc/net/bpf_jit_comp.c | 17 +++++++++--------
>   arch/sparc/net/bpf_jit_comp.c   | 18 ++++++++++--------
>   include/linux/skbuff.h          |  6 ++++++
>   net/core/filter.c               | 19 +++++++++----------
>   6 files changed, 54 insertions(+), 40 deletions(-)
>
