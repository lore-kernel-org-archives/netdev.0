From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Mon, 18 Jul 2016 14:48:11 +0200
Message-ID: <20160718124811.GB2979@pox.localdomain>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
 <20160714092543.776f8d8c@redhat.com>
 <20160715033057.GA98180@ast-mbp.thefacebook.com>
 <CALx6S34e73N6YA8AP67DAHEjcE-q5nO9q0Bk9motfbBKpB9T4g@mail.gmail.com>
 <20160715164744.GA3693@ast-mbp.thefacebook.com>
 <CALx6S37hihFayCBJcrr61WjER11=fDk_S_sGXaRSoC3Ukw93eA@mail.gmail.com>
 <20160718091023.GA29198@pox.localdomain>
 <CALx6S35a5jEbSLbDCMQ9Q7ngf2sAShsDdLZj+o-43ocOPb3N_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37849 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbcGRMsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 08:48:14 -0400
Received: by mail-wm0-f52.google.com with SMTP id i5so115128070wmg.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 05:48:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35a5jEbSLbDCMQ9Q7ngf2sAShsDdLZj+o-43ocOPb3N_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/16 at 01:39pm, Tom Herbert wrote:
> On Mon, Jul 18, 2016 at 11:10 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > I agree with that but I would like to keep the current per net_device
> > atomic properties.
> 
> I don't see that see that there is any synchronization guarantees
> using xchg. For instance, if the pointer is set right after being read
> by a thread for one queue and right before being read by a thread for
> another queue, this could result in the old and new program running
> concurrently or old one running after new. If we need to synchronize
> the operation across all queues then sequence
> ifdown,modify-config,ifup will work.

Right, there are no synchronization guarantees between threads and I
don't think that's needed. The guarantee that is provided is that if
I replace a BPF program, the replace either succeeds in which case
all packets have been either processed by the old or new program. Or
the replace failed in which case the old program was left intact and
all packets are still going through the old program.

This is a nice atomic replacement principle which would be nice to
preserve.
