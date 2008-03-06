From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Thu, 6 Mar 2008 16:41:58 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803061640380.4820@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
 <47CFF9B7.5060803@trash.net> <Pine.LNX.4.64.0803061612290.4202@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0803061618090.4378@sbz-30.cs.Helsinki.FI> <47D0014D.1060901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, clameter@sgi.com,
	joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47D0014D.1060901@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Mar 2008, Patrick McHardy wrote:
> It decides to reallocate when the remaining space isn't enough
> to hold the new data. NF_CT_EXT_MIN_SIZE is used to make sure it
> doesn't allocate anything smaller than the minimum slab size and
> hopefully avoid reallocations in the future. Unless I'm
> misunderstanding what ksize() does, the easiest way to get
> rid of this would be to replace NF_CT_EXT_MIN_SIZE by ksize(0).

I think you are misunderstanding ksize() (see mm/slub.c::ksize() for 
example). Furthermore, I think your current reallocation code is broken 
too as explained in a previous mail and my patch fixes that to behave as 
krealloc() does.

			Pekka
