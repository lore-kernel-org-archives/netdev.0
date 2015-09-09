From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Tue, 08 Sep 2015 22:59:57 -0700 (PDT)
Message-ID: <20150908.225957.1900230517834836583.davem@davemloft.net>
References: <55CDC51D.1060204@iogearbox.net>
	<20150817.140222.1763422851882964859.davem@davemloft.net>
	<55EDA536.10707@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, netdev@vger.kernel.org, fw@strlen.de
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbbIIF76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 01:59:58 -0400
In-Reply-To: <55EDA536.10707@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 07 Sep 2015 16:54:46 +0200

> On 08/17/2015 11:02 PM, David Miller wrote:
> ...
>> I would seriously rather see us do an expensive full copy of the SKB
>> than to have traffic which is unexpectedly invisible to taps.
> 
> I've been looking into this issue a bit further, so the copy for the
> tap seems doable, but while further going through the code to find
> similar
> issues elsewhere, and doing some experiments, it looks like we write
> shared info also in some edge-cases of upcalls such as nfqueue or ovs
> when mmaped netlink is used for rx. I did a test with nfqueue using
> the libmnl mmap branch [1].

Honestly if it's something isolated to something like nf_queue it can
be contained to just being a special fix there.

nf_queue is usually very special and needs hacks to handle things
properly since it acts as an "escape" point for various SKB things.

But if it's in OVS too....

I guess we need a more generic fix.
