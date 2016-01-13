From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 18:11:38 -0800
Message-ID: <1452651098.1223.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
	 <1452626228-15742-1-git-send-email-rabin@rab.in>
	 <1452628118.1223.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160112195356.GA34598@ast-mbp.thefacebook.com>
	 <5695653F.6030001@iogearbox.net>
	 <20160112204620.GA35080@ast-mbp.thefacebook.com>
	 <1452641302.1223.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160112234707.GA36167@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Rabin Vincent <rabin@rab.in>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34171 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbcAMCLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 21:11:41 -0500
Received: by mail-pf0-f169.google.com with SMTP id q63so74548895pfb.1
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 18:11:40 -0800 (PST)
In-Reply-To: <20160112234707.GA36167@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-12 at 15:47 -0800, Alexei Starovoitov wrote:

> I would agree if those loaded programs would do something sensible,
> but they're broken. As shown arm and arm64 would execute them
> differently without JIT, because HW treats such shifts differently.
> I also checked that libpcap is sane and doesn't generate broken shifts.
> imo we're not breaking backward compatiblity here.
> 

How did you prove a particular code path was even taken in a BPF
program ? This is new to me.

As I said, it is possible some guys never noticed their BPF program were
'broken' because this invalid shift was hidden in a dead code part.

So a program might appear as 'weak' when in fact its behavior was
absolutely correct.

You assume everybody uses libpcap, this is wrong, and for very obvious
reasons.

Try to encode the QUEUE, RXHASH, or CPU instructions in libpcap, for a
start.
