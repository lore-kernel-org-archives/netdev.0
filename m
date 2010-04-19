From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC] rps: shortcut net_rps_action()
Date: Mon, 19 Apr 2010 17:48:39 +0800
Message-ID: <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271362581.23780.12.camel@bigi> <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	<1271395106.16881.3645.camel@edumazet-laptop> <1271424065.4606.31.camel@bigi>
	<1271489739.16881.4586.camel@edumazet-laptop> <1271525519.3929.3.camel@bigi>
	<1271583573.16881.4798.camel@edumazet-laptop> <1271590476.16881.4925.camel@edumazet-laptop>
	<1271669822.16881.7520.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:26132 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab0DSJtA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 05:49:00 -0400
Received: by qw-out-2122.google.com with SMTP id 5so595349qwd.37
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 02:48:59 -0700 (PDT)
In-Reply-To: <1271669822.16881.7520.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 19, 2010 at 5:37 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> net_rps_action() is a bit expensive on NR_CPUS=3D64..4096 kernels, ev=
en if
> RPS is not active.
>
> I add a flag to scan cpumask only if at least one IPI was scheduled.
> Even cpumask_weight() might be expensive on some setups, where
> nr_cpumask_bits could be very big (4096 for example)

How about using a array to save the cpu IDs. The number of CPUs, to
which the IPI will be sent, should be small.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
