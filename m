From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH net-next 3/5] bpf/verifier: feed
 pointer-to-unknown-scalar casts into scalar ALU path
Date: Thu, 8 Jun 2017 09:50:06 -0700
Message-ID: <20170608165004.n5jc33pocxlytuvf@ast-mbp.dhcp.thefacebook.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
 <47ecf6ca-ae89-7fc3-3cd5-a47009b6ede9@solarflare.com>
 <20170608023540.5ecmmobhl2rtgrg5@ast-mbp>
 <2363ab5f-c344-900b-78ee-41e2eb0dd40f@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2363ab5f-c344-900b-78ee-41e2eb0dd40f@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 04:25:39PM +0100, Edward Cree wrote:
> On 08/06/17 03:35, Alexei Starovoitov wrote:
> > such large back and forth move doesn't help reviewing.
> > may be just merge it into previous patch?
> > Or keep that function in the right place in patch 2 already?
> I think 'diff' got a bit confused, and maybe with different options I could
>  have got it to produce something more readable.  But I think I will just
>  merge this into patch 2; it's only separate because it started out as an
>  experiment.

after sleeping on it I'm not sure we should be allowing such pointer
arithmetic. In normal C code people do fancy tricks with lower 3 bits
of the pointer, but in bpf code I cannot see such use case.
What kind of realistic code will be doing ptr & 0x40 ?
