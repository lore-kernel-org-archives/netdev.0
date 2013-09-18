From: Ethan Tuttle <ethan@ethantuttle.com>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Tue, 17 Sep 2013 23:30:56 -0700
Message-ID: <CACzLR4t2ABZdRk40VUhLtDKXX2PQiSVoQZQ4coQkNkvETnY6Rw@mail.gmail.com>
References: <20130915205701.5c61a444@skate>
	<20130916065047.GH27487@1wt.eu>
	<20130916175152.4e013457@skate>
	<CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com>
	<20130916163937.GC3188@1wt.eu>
	<20130916164412.GD3188@1wt.eu>
	<CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com>
	<20130916174708.GG3188@1wt.eu>
	<20130916182807.GO12758@n2100.arm.linux.org.uk>
	<CACzLR4suLD90p=sEhB-qg1u35t66zKfrGQref1jX42fEfu3D8g@mail.gmail.com>
	<20130917060111.GB9325@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	=?ISO-8859-1?Q?Gregory_Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:49715 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab3IRGa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 02:30:57 -0400
Received: by mail-wg0-f50.google.com with SMTP id f12so6003618wgh.17
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 23:30:56 -0700 (PDT)
In-Reply-To: <20130917060111.GB9325@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 11:01 PM, Willy Tarreau <w@1wt.eu> wrote:
> Next step should be that you test both kernels to be sure.

Thanks for the kernel images, Willy.  I'm still experimenting but
initial results are strange: I haven't seen a crash from the -ethan
image you provided, nor by a kernel with that config that I built
myself.  The config is only different from my crashing config by a few
options.  So perhaps some combination of options prevents the crash.
I'll see if I can narrow it down.

For a moment I thought I found a likely culprit: all along I've been
loading my kernel in to 0x02000000 in uboot, while the stock uboot env
(and Willy) uses 0x6400000.  But I've seen at least one
__rcu_read_lock oops since switching to 0x6400000.  So I guess I can
rule that out.

Thanks,

Ethan
