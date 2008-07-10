From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Thu, 10 Jul 2008 13:13:57 +0200
Message-ID: <20080710111357.GR20815@postel.suug.ch>
References: <1214428440.6908.1.camel@brick> <20080627.201649.95998057.davem@davemloft.net> <20080629095424.GM20815@postel.suug.ch> <1214762490.6037.9.camel@brick> <20080629232638.GO20815@postel.suug.ch> <1215223840.27271.7.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39436 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194AbYGJLNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 07:13:37 -0400
Content-Disposition: inline
In-Reply-To: <1215223840.27271.7.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Harvey Harrison <harvey.harrison@gmail.com> 2008-07-04 19:10
> On Mon, 2008-06-30 at 01:26 +0200, Thomas Graf wrote:
> > * Harvey Harrison <harvey.harrison@gmail.com> 2008-06-29 11:01
> > > OK, but be16/32_to_cpu is a no-op on be-arches, so there is a bug here on
> > > big-endian machines as they won't switch it back, your simplified patch
> > > is actually a bugfix in that case.
> > 
> > I noticed that my change wouldn't be correct. The point is to allow
> > userspace to convert the filter values to big endian once, supply them
> > to the kernel and compare big endian values directly. The be16/32_to_cpu
> > convertion is available to support greater-than/lesser-than on little
> > endian architectures.
> 
> Thomas, maybe I'm just being slow, put if it's always a be-value, why
> not the following:
> 
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Subject: [PATCH] net: em_cmp.c use unaligned access helper
> 
> ptr pointers to a big endian value, instead of constructing a be
> value and conditionally byteswapping on little-endian arches, use
> the unaligned to access helpers return a cpu-endian value.

em_cmp is based on the u32 classifier which compares everything in
be, it is faster than swapping every value but only works for eq/ne
comparisons. Some people have just gotten used to work with be
when filtering on addresses and port numbers.

em_cmp additionally supports gt/lt operations which only work in
host byte order, therefore the flag TCP_EM_CMP_TRANS was added to
trigger this.

Enforcing host byte order in all cases would probably be simpler
but it can't be changed now as it would break scripts.
