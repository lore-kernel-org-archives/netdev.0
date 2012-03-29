From: Li Yu <raise.sail@gmail.com>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 17:49:18 +0800
Message-ID: <4F74301E.9020702@gmail.com>
References: <20120329074443.GB2098@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	davem@davemloft.net, bhutchings@solarflare.com,
	shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39240 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab2C2Jt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 05:49:29 -0400
Received: by iagz16 with SMTP id z16so2804228iag.19
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 02:49:29 -0700 (PDT)
In-Reply-To: <20120329074443.GB2098@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B403=E6=9C=8829=E6=97=A5 15:44, Jiri Pirko =E5=86=99=
=E9=81=93:
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
>     the patch cooked up already)
>
> 2) extend current BPF machine to allow XOR operation. Not sure if thi=
s
>     is doable or what the best of doing this is.
>
> 3) add possibility to pass some data to the machine via
>     pre-filling "Scratch Memory Store". I think this can be done easi=
ly
>     moving "u32 mem[BPF_MEMWORDS];" to bpf_func caller and pass it as=
 the
>     second function parameter. That should not break anything.
>
> Then the computed hash can be either stored into Scratch memory or re=
turned
> directly (where ordinary sk filters return len).
>
> Does this seems reasonable? Thoughts, comments?
>

Very interesting.

I am working on a blktrace like utility for networking subsystem. It
needs a trace events filter to avoid to generate too much results which
user does not interesting, it seem that the generic BPF is the best
choice here.

So far, the "skbtrace" need to filter two kinds of objects: the skb and=
=20
socket, so I think that above "Scratch Memory Store" is necessary indee=
d.

Thanks.

Yu

> Thanks!
>
> Jirka
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
