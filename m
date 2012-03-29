From: Nuno Martins <nuno.martins@caixamagica.pt>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 15:04:29 +0100
Message-ID: <CAAgcAh0QbHoi0VfFfTC1RLfzm2AbXBD1WmEQ2-958vQ0R=MXsA@mail.gmail.com>
References: <20120329074443.GB2098@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	davem@davemloft.net, bhutchings@solarflare.com,
	shemminger@vyatta.com, Alfredo Matos <alfredo.matos@caixamagica.pt>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60879 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758756Ab2C2OEb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 10:04:31 -0400
Received: by bkcik5 with SMTP id ik5so1993020bkc.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 07:04:30 -0700 (PDT)
In-Reply-To: <20120329074443.GB2098@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 29, 2012 at 8:44 AM, Jiri Pirko <jpirko@redhat.com> wrote:
> Hi all.
>
> I came to an idea of using BPF infrastructure currently used in kerne=
l,
> for computing hashes selecting TX ports in team device. Since the sam=
e
> data (skb) are alalyzed/used as for socket filtering, BPF seems so be=
 quite
> suitable for this. It would allow userspace daemon to specify various
> kinds of TX selection algorithms.
>
> Here are proposed things to be done:
> 1) introduce in-kernel api for creating sk-unattached filters (I have
> =A0 the patch cooked up already)
>
> 2) extend current BPF machine to allow XOR operation. Not sure if thi=
s
> =A0 is doable or what the best of doing this is.
>
> 3) add possibility to pass some data to the machine via
> =A0 pre-filling "Scratch Memory Store". I think this can be done easi=
ly
> =A0 moving "u32 mem[BPF_MEMWORDS];" to bpf_func caller and pass it as=
 the
> =A0 second function parameter. That should not break anything.
>
> Then the computed hash can be either stored into Scratch memory or re=
turned
> directly (where ordinary sk filters return len).
>
> Does this seems reasonable? Thoughts, comments?
>

Hi all,

I've also been working on mechanism that requires creating custom BFP
filters, but for PID based packet filtering. It allows attaching
custom filters to a
socket, through setsocketopt, making it possible to detect when packets=
 belongs
 to a target process id (previously identified through kprobes).

The in-kernel api we use, enables registering and unregistering filter
functions,
 which are then stored on a filter function list.

When attaching the custom filter function, it replaces the current
filter, releasing the JIT code if necessary. However, the newly
attached filter function does not get JIT compiled (bpf_jit_compile)
to allow custom functions without having to provide the corresponding
ASM code.

Using the JIT extensions that Jirka mentions in step 3 could also allow=
s to
compile custom.

We are in the process of making the source code available through a
project page dedicated to PID monitoring, and will (hopefully) send a
Q/RFC to this list tomorrow.

> Thanks!

Thanks.

>
> Jirka
>

Nuno Martins

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
