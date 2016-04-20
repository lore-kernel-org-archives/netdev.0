From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: skb_at_tc_ingress helper breaks compilation of oot modules
Date: Wed, 20 Apr 2016 10:33:09 -0700
Message-ID: <20160420173307.GA31849@ast-mbp.thefacebook.com>
References: <20160420102148.GA18615@echse.zoo>
 <57175C13.8080109@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Saitz <ingo@stud.uni-hannover.de>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35928 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbcDTRdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 13:33:15 -0400
Received: by mail-pa0-f41.google.com with SMTP id er2so19789973pad.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 10:33:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57175C13.8080109@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2016 at 12:38:11PM +0200, Daniel Borkmann wrote:
> On 04/20/2016 12:21 PM, Ingo Saitz wrote:
> >In Linux 4.5, when CONFIG_NET_CLS_ACT is defined, compilation of out of
> >tree modules breaks with undeclared functions/constants. The culprit is:
> >
> >commit fdc5432a7b44ab7de17141beec19d946b9344e91
> >Author: Daniel Borkmann <daniel@iogearbox.net>
> >Date:   Thu Jan 7 15:50:22 2016 +0100
> >
> >     net, sched: add skb_at_tc_ingress helper
> >
> >which uses G_TC_AT and AT_INGRESS but only includes linux/pkt_cls.h,
> >which does not include these #defines for oot builds. Unfortunately I'm
> >not sure what the correct fix is, maybe the uapi folks could help, but i
> >attached a simple testcase and build log (Makefile is straight from
> >kernelnewbies).
> 
> Hmm, your fail.c test case only contains '#include <net/ipv6.h>'?
> 
> Note, upstream kernel never cared about out-of-tree modules, only
> in-tree code. ;) Did you run into an issue with any in-tree code?

I'm glad it broke out of tree module. We should do it more often.
llvm constantly reshuffles internal api to incentivize upstreaming
and working with the community.
