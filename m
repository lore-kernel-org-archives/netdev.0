From: Jiri Pirko <jpirko@redhat.com>
Subject: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 09:44:43 +0200
Message-ID: <20120329074443.GB2098@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750738Ab2C2Hos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 03:44:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

I came to an idea of using BPF infrastructure currently used in kernel,
for computing hashes selecting TX ports in team device. Since the same
data (skb) are alalyzed/used as for socket filtering, BPF seems so be quite
suitable for this. It would allow userspace daemon to specify various
kinds of TX selection algorithms.

Here are proposed things to be done:
1) introduce in-kernel api for creating sk-unattached filters (I have
   the patch cooked up already)

2) extend current BPF machine to allow XOR operation. Not sure if this
   is doable or what the best of doing this is.

3) add possibility to pass some data to the machine via
   pre-filling "Scratch Memory Store". I think this can be done easily
   moving "u32 mem[BPF_MEMWORDS];" to bpf_func caller and pass it as the
   second function parameter. That should not break anything.

Then the computed hash can be either stored into Scratch memory or returned
directly (where ordinary sk filters return len).

Does this seems reasonable? Thoughts, comments?

Thanks!

Jirka
