From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: Re: [PATCH net-next] ebpf: move CONFIG_BPF_SYSCALL-only function declarations
Date: Mon, 2 Mar 2015 19:15:56 -0800
Message-ID: <CAMEtUuwtNs_iM5LnJ58ff-v08xzmMsRgAk_OfqsYpQv_JzCvcQ@mail.gmail.com>
References: <CAMEtUuw+6j5uNCxV7M7HXm_GUha9Dpk6Y-h6ey0yMQ+7Z_Wa4Q@mail.gmail.com>
 <54F526B4.8060506@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:49677 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807AbbCCDQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 22:16:17 -0500
Received: by mail-qg0-f43.google.com with SMTP id h3so5755464qgf.2
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 19:16:16 -0800 (PST)
In-Reply-To: <54F526B4.8060506@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 7:12 PM, Masami Hiramatsu
<masami.hiramatsu.pt@hitachi.com> wrote:
> (2015/03/03 2:35), Alexei Starovoitov wrote:
>> On Mon, Mar 2, 2015 at 6:21 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>> Masami noted that it would be better to hide the remaining CONFIG_BPF_SYSCALL-only
>>> function declarations within the BPF header ifdef, w/o else path dummy alternatives
>>> since these functions are not supposed to have a user outside of CONFIG_BPF_SYSCALL.
>>
>> So far we didn't have anyone trying to add new map types
>> outside of kernel/bpf/, so this patch is a defensive move.
>> Such potential future abuser will get compile error for
>> missing bpf_register_map_type() instead of linker error for the same.
>> Not sure that's really needed.
>> Also bpf_map_put() and bpf_map_get() are only used
>> by bpf syscall and verifier. imo moving them under ifdef is overkill.
>
> No, not overkill. This patch becomes good description about the code to
> reader who learns the eBPF. It tells them what functions are provided
> when the kconfig is set or not.
>
> And compiler error is better since abuser would get it before
> compiling all other object :)

Just as Daniel, I don't have strong preference one way or another.
Dave already applied it to net-next, so hopefully now you can
do some more eBPF coding :)
