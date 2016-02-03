From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Wed, 3 Feb 2016 12:31:25 -0500
Message-ID: <20160203173125.GA14627@oracle.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <20160202003127.GA25154@oracle.com>
 <CALx6S34MGwp2m=QmfQ36tWnaWbFXvMG63sj7Nz1KgMtegxn-2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20025 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbcBCRbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 12:31:39 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S34MGwp2m=QmfQ36tWnaWbFXvMG63sj7Nz1KgMtegxn-2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/03/16 09:07), Tom Herbert wrote:
> > Kernel unaligned access at TPC[9150dc] ipv4_neigh_lookup+0x38/0x170
> 
> Sowmini,
> 
> This doesn't look like a hard crash to me. Instead of trying to fix
> all the alignment issues for Sparc, can we just take the trap, fix up
> the load, and continue without any further fuss? Performance might
> suffer, but it doesn't seem like the bad alignments are happening in
> critical paths.
> 

None of these things is a hard crash, but they are 

(a) quite noisy 
(b) I'm able to generate alignment falls merely by configuring
    tunnels, and it gets worse when I disable RSS and use RFS/RPS
    instead. So "critical path" might need some definition.
(c) a perf risk for other platforms as well, even when they dont
    complain noisily about it.

--Sowmini
