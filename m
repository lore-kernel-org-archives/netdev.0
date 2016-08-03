From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and
 rewrite
Date: Wed, 03 Aug 2016 11:31:20 -0700 (PDT)
Message-ID: <20160803.113120.723316810333787446.davem@davemloft.net>
References: <20160803171118.GA37742@ast-mbp.thefacebook.com>
	<CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com>
	<20160803182950.GA10130@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, gerlitz.or@gmail.com, john.fastabend@gmail.com,
	hannes@stressinduktion.org, tgraf@suug.ch, daniel@iogearbox.net,
	ttoukan.linux@gmail.com, haoxuany@fb.com
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbcHCSbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 14:31:21 -0400
In-Reply-To: <20160803182950.GA10130@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Wed, 3 Aug 2016 11:29:52 -0700

> On Wed, Aug 03, 2016 at 10:29:58AM -0700, Tom Herbert wrote:
>> On Wed, Aug 3, 2016 at 10:11 AM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Wed, Aug 03, 2016 at 10:01:54AM -0700, Tom Herbert wrote:
>> >> On Tue, Jul 19, 2016 at 12:16 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> [...]
>> >> > +SEC("xdp1")
>> >> > +int xdp_prog1(struct xdp_md *ctx)
>> >> > +{
>> >> > +       void *data_end = (void *)(long)ctx->data_end;
>> >> > +       void *data = (void *)(long)ctx->data;
>> >>
>> >> Brendan,
>> >>
>> >> It seems that the cast to long here is done because data_end and data
>> >> are u32s in xdp_md. So the effect is that we are upcasting a
>> >> thirty-bit integer into a sixty-four bit pointer (in fact without the
>> >> cast we see compiler warnings). I don't understand how this can be
>> >> correct. Can you shed some light on this?
>> >
>> > please see:
>> > http://lists.iovisor.org/pipermail/iovisor-dev/2016-August/000355.html
>> >
>> That doesn't explain it. The only thing I can figure is that there is
>> an implicit assumption somewhere that even though the pointer size may
>> be 64 bits, only the low order thirty-two bits are relevant in this
>> environment (i.e. upper bit are always zero for any pointers)-- so
>> then it would safe store pointers as u32 and to upcast them to void *.
> No, the actual pointer storage is always void* sized (see struct
> xdp_buff). The mangling is cosmetic. The verifier converts the
> underlying bpf load instruction to the right sized operation.

And this is what Alexei meant by "meta".  Tom this stuff works just
fine.
