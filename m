From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Fri, 11 Jul 2008 00:00:30 +0200
Message-ID: <20080710220030.GA29558@orion.carnet.hr>
References: <4863DA40.9050508@broadcom.com> <20080709164619.GA26098@orion.carnet.hr> <1215622625.5532.43.camel@dell> <20080709.164659.157912631.davem@davemloft.net> <1215723617.6901.3.camel@dell> <20080710212324.GA22521@orion.carnet.hr> <1215725921.6901.10.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"billfink@mindspring.com" <billfink@mindspring.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:39087 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366AbYGJWAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 18:00:34 -0400
Content-Disposition: inline
In-Reply-To: <1215725921.6901.10.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 02:38:41PM -0700, Michael Chan wrote:
> On Thu, 2008-07-10 at 14:23 -0700, Josip Rodin wrote:
> > I'll try it - but just as I was reading this e-mail, the machine
> > managed to
> > crash :(
> > 
> > The log was:
> > 
> > BUG: unable to handle kernel NULL pointer dereference at
> > 00000000000000b8
> > IP: [<ffffffff8807ad7e>] :bnx2:bnx2_tx_int+0x7e/0x3f0
> 
> This is the same crash that you originally reported.  The driver was
> referencing a NULL SKB because the skb_shinfo(skb)->nr_frags was
> modified on the previous packet in the TX ring.
> 
> If you had applied my debug patch #1 that I posted several weeks ago, it
> should have avoided this because we should have saved away the nr_frags
> for every packet on the TX ring.

It was that same patched kernel that crashed nevertheless.

-- 
Josip Rodin
mirrors@debian.org
