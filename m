From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] ebpf: move CONFIG_BPF_SYSCALL-only function
 declarations
Date: Mon, 02 Mar 2015 18:41:47 +0100
Message-ID: <54F4A0DB.90004@iogearbox.net>
References: <CAMEtUuw+6j5uNCxV7M7HXm_GUha9Dpk6Y-h6ey0yMQ+7Z_Wa4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54062 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754954AbbCBRlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:41:55 -0500
In-Reply-To: <CAMEtUuw+6j5uNCxV7M7HXm_GUha9Dpk6Y-h6ey0yMQ+7Z_Wa4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2015 06:35 PM, Alexei Starovoitov wrote:
> On Mon, Mar 2, 2015 at 6:21 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Masami noted that it would be better to hide the remaining CONFIG_BPF_SYSCALL-only
>> function declarations within the BPF header ifdef, w/o else path dummy alternatives
>> since these functions are not supposed to have a user outside of CONFIG_BPF_SYSCALL.
>
> So far we didn't have anyone trying to add new map types
> outside of kernel/bpf/, so this patch is a defensive move.
> Such potential future abuser will get compile error for
> missing bpf_register_map_type() instead of linker error for the same.
> Not sure that's really needed.
> Also bpf_map_put() and bpf_map_get() are only used
> by bpf syscall and verifier. imo moving them under ifdef is overkill.
>
> I think ifdef should only be used for function that have
> real and dummy bodies.
> Today we have three:
> bpf_register_prog_type(), bpf_prog_get() and bpf_prog_put()
> and that makes sense.
>
> Hiding *map*() functions seems unnecessary.
> I think linker error is good enough.

I don't have a strong opinion here, we do similar hiding elsewhere,
e.g. in CONFIG_BPF_JIT. If it's for the sake that Masami can read the
code better, I'm okay with it, perhaps that will lead him to write
patches for eBPF code. ;)
