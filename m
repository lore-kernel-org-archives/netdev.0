From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: skb_at_tc_ingress helper breaks compilation of oot modules
Date: Wed, 20 Apr 2016 12:38:11 +0200
Message-ID: <57175C13.8080109@iogearbox.net>
References: <20160420102148.GA18615@echse.zoo>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ingo Saitz <ingo@stud.uni-hannover.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48460 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932440AbcDTKiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 06:38:13 -0400
In-Reply-To: <20160420102148.GA18615@echse.zoo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2016 12:21 PM, Ingo Saitz wrote:
> In Linux 4.5, when CONFIG_NET_CLS_ACT is defined, compilation of out of
> tree modules breaks with undeclared functions/constants. The culprit is:
>
> commit fdc5432a7b44ab7de17141beec19d946b9344e91
> Author: Daniel Borkmann <daniel@iogearbox.net>
> Date:   Thu Jan 7 15:50:22 2016 +0100
>
>      net, sched: add skb_at_tc_ingress helper
>
> which uses G_TC_AT and AT_INGRESS but only includes linux/pkt_cls.h,
> which does not include these #defines for oot builds. Unfortunately I'm
> not sure what the correct fix is, maybe the uapi folks could help, but i
> attached a simple testcase and build log (Makefile is straight from
> kernelnewbies).

Hmm, your fail.c test case only contains '#include <net/ipv6.h>'?

Note, upstream kernel never cared about out-of-tree modules, only
in-tree code. ;) Did you run into an issue with any in-tree code?

Thanks,
Daniel
