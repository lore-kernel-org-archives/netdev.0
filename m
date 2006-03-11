From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 8/8] [I/OAT] TCP recv offload to I/OAT
Date: Sat, 11 Mar 2006 01:41:03 -0800
Message-ID: <20060311014103.5d04f863.akpm@osdl.org>
References: <20060311022759.3950.58788.stgit@gitlost.site>
	<20060311022936.3950.86896.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932441AbWCKJnP@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060311022936.3950.86896.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> Locks down user pages and sets up for DMA in tcp_recvmsg, then calls
>  dma_async_try_early_copy in tcp_v4_do_rcv

All those ifdefs are still there.  They really do put a maintenance burden
on, of all places, net/ipv4/tcp.c.  Please find a way of abstracting out
the conceptual additions which IOAT makes to TCP and to wrap that into
inline functions, etc.  See how tidily NF_HOOK() has inserted things into
the net stack.

Also, for something which is billed as an performance enhancement,
benchmark numbers are the key thing which we need to judge the desirability
of these changes.  What is the plan there?

Thanks.
