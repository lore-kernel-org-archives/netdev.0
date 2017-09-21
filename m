From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Thu, 21 Sep 2017 12:44:28 -0700
Message-ID: <20170921194426.tnd5xos5irm3gred@ast-mbp>
References: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com>
 <20170921155215.jta52sesbiq54vri@ast-mbp>
 <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
 <CAH3MdRWAHJS8Y8ketOAghYyorVUp6JijjZcSVY7gOiGAr7e_pw@mail.gmail.com>
 <207ecd4c-b1b4-3dcd-62a6-30824c19dbf7@solarflare.com>
 <59C4131D.8050003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>, Y Song <ys114321@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:51675 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751729AbdIUTob (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 15:44:31 -0400
Received: by mail-pf0-f179.google.com with SMTP id b70so3700726pfl.8
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 12:44:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <59C4131D.8050003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 09:29:33PM +0200, Daniel Borkmann wrote:
> On 09/21/2017 06:58 PM, Edward Cree wrote:
> > On 21/09/17 17:40, Y Song wrote:
> > > On Thu, Sep 21, 2017 at 9:24 AM, Edward Cree <ecree@solarflare.com> wrote:
> > > > On 21/09/17 16:52, Alexei Starovoitov wrote:
> > > > > imo
> > > > > (u16) r4 endian be
> > > > > isn't intuitive.
> > > > > Can we come up with some better syntax?
> > > > > Like
> > > > > bswap16be r4
> > > > > bswap32le r4
> > > > Hmm, I don't like these, since bswapbe is a swap on *le* and a nop on be.
> 
> Agree, a bit too much 'swap' semantics in the name that could be
> confusing perhaps, at least the be/le could be missed easily.
> 
> > > > > or
> > > > > 
> > > > > to_be16 r4
> > > > > to_le32 r4
> > > > And the problem here is that it's not just to_be, it's also from_be.
> 
> More intuitive, but agree on the from_be/le. Maybe we should
> just drop the "to_" prefix altogether, and leave the rest as is since
> it's not surrounded by braces, it's also not a cast but rather an op.

'be16 r4' is ambiguous regarding upper bits.

what about my earlier suggestion:
r4 = (be16) (u16) r4
r4 = (le64) (u64) r4

It will be pretty clear what instruction is doing (that upper bits become zero).
