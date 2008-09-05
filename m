From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 19:38:11 +0400
Message-ID: <20080905153811.GA3596@2ka.mipt.ru>
References: <20080905113112.GA29926@2ka.mipt.ru> <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com> <20080905131618.GB12246@2ka.mipt.ru> <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com> <20080905133748.GA28656@2ka.mipt.ru> <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com> <20080905141911.GA16586@2ka.mipt.ru> <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com> <20080905145902.GA12762@2ka.mipt.ru> <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:55725 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810AbYIEPii (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 11:38:38 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Sep 05, 2008 at 05:30:39PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> > Well, udp_sendpage() needs to be extended to only append page when there
> > is anough free space there, otherwise push given frame and create next
> > packet.
> >
> Ok, I'll do a patch and let you know result.

Great, thank you. But it should take into account UDP nature: data is
not allowed to be split between ip packets like with TCP.

> > I meant you get a pointer by mapping some file in tmpfs (for example)
> > and then use some offset variable to store where you put your last data
> > (either packet header, or data itself), so that any subsequent write to
> > that area (either new packet header or dma data placement) would put
> > data just after the previous chunk. Thus after you have put number of
> > headers and appropriate data chunks, you could call sendfile() and reset
> > offset to the beginning of the mapped area.
> 
> If I understand well, there is no link between start of ethernet frame
> and packet header ?

Ethernet header is appended by the network core itself, likely core will
just allocate skb with small data area, put there an ethernet and udp/ip
headers and attach pages from the file. If hardware does not support
checksumming and scatter/gather, things will be different.

> App protocol must support packet loss ^^

I think matter of packet loss relevance here is just the same like with
any other sending method.

-- 
	Evgeniy Polyakov
