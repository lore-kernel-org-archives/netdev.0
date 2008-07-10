From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 10 Jul 2008 14:38:41 -0700
Message-ID: <1215725921.6901.10.camel@dell>
References: <4863DA40.9050508@broadcom.com>
 <20080709164619.GA26098@orion.carnet.hr>
 <1215622625.5532.43.camel@dell>
 <20080709.164659.157912631.davem@davemloft.net>
 <1215723617.6901.3.camel@dell> <20080710212324.GA22521@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"billfink@mindspring.com" <billfink@mindspring.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"mirrors@debian.org" <mirrors@debian.org>
To: "Josip Rodin" <joy@entuzijast.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2836 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbYGJVgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:36:03 -0400
In-Reply-To: <20080710212324.GA22521@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-07-10 at 14:23 -0700, Josip Rodin wrote:
> I'll try it - but just as I was reading this e-mail, the machine
> managed to
> crash :(
> 
> The log was:
> 
> BUG: unable to handle kernel NULL pointer dereference at
> 00000000000000b8
> IP: [<ffffffff8807ad7e>] :bnx2:bnx2_tx_int+0x7e/0x3f0

This is the same crash that you originally reported.  The driver was
referencing a NULL SKB because the skb_shinfo(skb)->nr_frags was
modified on the previous packet in the TX ring.

If you had applied my debug patch #1 that I posted several weeks ago, it
should have avoided this because we should have saved away the nr_frags
for every packet on the TX ring.


