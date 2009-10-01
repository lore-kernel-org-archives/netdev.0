From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Thu, 1 Oct 2009 16:17:06 -0600
Message-ID: <20091001221706.GA5191@obsidianresearch.com>
References: <20090930004820.GC19540@obsidianresearch.com> <4AC2E481.5060509@gmail.com> <20090930054031.GY22310@obsidianresearch.com> <4AC2F1D9.1010801@gmail.com> <4AC2F3E4.5000904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 139-142-54-143.atc.vaillant.ca ([139.142.54.143]:56236 "EHLO
	quartz.edm.orcorp.ca" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752283AbZJAWRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 18:17:04 -0400
Content-Disposition: inline
In-Reply-To: <4AC2F3E4.5000904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2009 at 08:00:04AM +0200, Eric Dumazet wrote:

> >> I admit I don't understand why SPLICE_F_NONBLOCK exists, it seems very
> >> un-unixy to have a syscall completely ignore the NONBLOCK flag of the
> >> fd it is called on. Ie setting NONBLOCK on the pipe itself does
> >> nothing when using splice..
> > 
> > Hmm, good question, I dont have the answer but I'll digg one.
> > 
> 
> commit	29e350944fdc2dfca102500790d8ad6d6ff4f69d
> splice: add SPLICE_F_NONBLOCK flag
> 
> It doesn't make the splice itself necessarily nonblocking (because the
> actual file descriptors that are spliced from/to may block unless they
> have the O_NONBLOCK flag set), but it makes the splice pipe operations
> nonblocking.
> 
> Signed-off-by: Linus Torvalds <torvalds@osdl.org>
> 
> See Linus intention was pretty clear : O_NONBLOCK should be taken
> into account by 'actual file that are spliced from/to', regardless
> of SPLICE_F_NONBLOCK flag

Yes, that seems reasonable.

What confuses me is that if O_NONBLOCK is set on the _pipe_ and
SPICE_F_NONBLOCK is not set on the splice call the splice still blocks
- that is unlike other unix apis, eg MSG_DONTWAIT

It seems to me that SPICE_F_NONBLOCK should be or'd with O_NONBLOCK on
the pipe?

Thanks,
Jason
