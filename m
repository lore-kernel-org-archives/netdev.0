From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v10 12/12] bpf: add sample for xdp forwarding and rewrite
Date: Thu, 04 Aug 2016 01:18:36 +0200
Message-ID: <57A27BCC.4000608@iogearbox.net>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com> <1468955817-10604-13-git-send-email-bblanco@plumgrid.com> <CALx6S34b1O6iiFn6M2=xX3iduGWDQm=G+jweYVvGqY-xa4E2sg@mail.gmail.com> <20160803171118.GA37742@ast-mbp.thefacebook.com> <CALx6S36ARsfC8XxPHYsbD+T6Dx3SOgxdxv2CDJWuVZGf+H1oAw@mail.gmail.com> <20160803182950.GA10130@gmail.com> <CALx6S36k=kfrvY+aFD4rfq+nUJfd5-=8+26uk-=8dCFye_c-Ow@mail.gmail.com> <20160803223632.GA42605@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
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
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Aaron Yue <haoxuany@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40311 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758389AbcHCXTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 19:19:40 -0400
In-Reply-To: <20160803223632.GA42605@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/2016 12:36 AM, Alexei Starovoitov wrote:
> On Wed, Aug 03, 2016 at 12:06:55PM -0700, Tom Herbert wrote:
[...]
>> This is not at all obvious to XDP programmer. The type of ctx
>> structure is xdp_md and the definition of that structure in
>> uapi/linux/bpf.h says that the fields in the that structure are __u32.
>> So when I, as a user naive the inner workings of the verifier, read
>> this code it sure looks like we are upcasting a 32 bit value to a 64
>> bit value-- that does not seem right at all and the compiler
>> apparently concurs my point of view. If the code ends up being correct
>> anyway, then the obvious answer to have an explicit cast that points
>> out the special nature of this cast. Blindly casting to u32 to long
>> for the purposes of assigning to a pointer is only going to confuse
>> more people as it has me.
>
> Agree. Would be nice to have few helpers. The question is whether
> they belong in bpf.h. Probably not, since they're not kernel abi.

Yeah, fully agree, they don't belong into uapi.

> For the same reasons we didn't include instruction building macros
> like BPF_ALU64_REG and instead kept them in samples/bpf/libbpf.h

+1

> Here probably four static inline functions are needed. Two for __sk_buff
> and two for xpd_md. That should make xdp*_kern.c examples a bit easier
> to read.

Yeah, all these bits should go into some library headers that the test
cases make use of (and make them easier to parse for developers).
