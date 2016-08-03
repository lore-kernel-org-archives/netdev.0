From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and rewrite
Date: Wed, 3 Aug 2016 11:29:52 -0700
Message-ID: <20160803182950.GA10130@gmail.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-13-git-send-email-bblanco@plumgrid.com>
 <CALx6S34b1O6iiFn6M2=xX3iduGWDQm=G+jweYVvGqY-xa4E2sg@mail.gmail.com>
 <20160803171118.GA37742@ast-mbp.thefacebook.com>
 <CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Aaron Yue <haoxuany@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36065 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbcHCSaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 14:30:18 -0400
Received: by mail-pf0-f178.google.com with SMTP id h186so79670010pfg.3
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 11:29:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 03, 2016 at 10:29:58AM -0700, Tom Herbert wrote:
> On Wed, Aug 3, 2016 at 10:11 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Wed, Aug 03, 2016 at 10:01:54AM -0700, Tom Herbert wrote:
> >> On Tue, Jul 19, 2016 at 12:16 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
[...]
> >> > +SEC("xdp1")
> >> > +int xdp_prog1(struct xdp_md *ctx)
> >> > +{
> >> > +       void *data_end = (void *)(long)ctx->data_end;
> >> > +       void *data = (void *)(long)ctx->data;
> >>
> >> Brendan,
> >>
> >> It seems that the cast to long here is done because data_end and data
> >> are u32s in xdp_md. So the effect is that we are upcasting a
> >> thirty-bit integer into a sixty-four bit pointer (in fact without the
> >> cast we see compiler warnings). I don't understand how this can be
> >> correct. Can you shed some light on this?
> >
> > please see:
> > http://lists.iovisor.org/pipermail/iovisor-dev/2016-August/000355.html
> >
> That doesn't explain it. The only thing I can figure is that there is
> an implicit assumption somewhere that even though the pointer size may
> be 64 bits, only the low order thirty-two bits are relevant in this
> environment (i.e. upper bit are always zero for any pointers)-- so
> then it would safe store pointers as u32 and to upcast them to void *.
No, the actual pointer storage is always void* sized (see struct
xdp_buff). The mangling is cosmetic. The verifier converts the
underlying bpf load instruction to the right sized operation.
> If this is indeed the case, then we really need to make this explicit
> to the user. Casting to long without comment just to avoid the
> compiler warning is not good programming style, maybe a function
> xdp_md_data_to_ptr or the like could be used.
> 
> Tom
