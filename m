From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Add boundary check on ioctl arguments
Date: Wed, 30 Sep 2009 22:41:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0909302231360.2853@u.domain.uli>
References: <20090930131109.2b3f71b8@infradead.org> <4AC35F44.60707@google.com>
 <20090930171833.5ce0011d@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hannes Eder <heder@google.com>,
	Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755225AbZI3Tkw@vger.kernel.org>
In-Reply-To: <20090930171833.5ce0011d@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 30 Sep 2009, Arjan van de Ven wrote:

> fair enough; updated patch below
> 
> >From 28ae217858e683c0c94c02219d46a9a9c87f61c6 Mon Sep 17 00:00:00 2001
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Wed, 30 Sep 2009 13:05:51 +0200
> Subject: [PATCH] ipvs: Add boundary check on ioctl arguments
> 
> The ipvs code has a nifty system for doing the size of ioctl command copies;
> it defines an array with values into which it indexes the cmd to find the
> right length.
> 
> Unfortunately, the ipvs code forgot to check if the cmd was in the range
> that the array provides, allowing for an index outside of the array,
> which then gives a "garbage" result into the length, which then gets
> used for copying into a stack buffer.

	do_ip_vs_get_ctl and do_ip_vs_set_ctl are nf_sockopt_ops
handlers, so the range is checked by nf_sockopt_find() in Netfilter
code. get_arglen[] and set_arglen[] are minimum values for
the length and they can be 0. Later len can be checked
additionally and surely can exceed 128 (include/linux/ip_vs.h has
all user structures). Can you show the exact cmd and len
used, may be there is error in some command or may be the
provided user structure is wrong?

Regards

--
Julian Anastasov <ja@ssi.bg>
