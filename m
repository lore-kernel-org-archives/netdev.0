From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in
 tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 15:48:40 -0400 (EDT)
Message-ID: <20160331.154840.206151100376077818.davem@davemloft.net>
References: <20160331.152149.396188904137423987.davem@davemloft.net>
	<56FD795C.9090903@stressinduktion.org>
	<20160331193154.GA63937@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, daniel@iogearbox.net,
	eric.dumazet@gmail.com, mkubecek@suse.cz, sasha.levin@oracle.com,
	jslaby@suse.cz, mst@redhat.com, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757065AbcCaTsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 15:48:43 -0400
In-Reply-To: <20160331193154.GA63937@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Thu, 31 Mar 2016 12:31:56 -0700

> On Thu, Mar 31, 2016 at 09:24:12PM +0200, Hannes Frederic Sowa wrote:
>> Hello,
>> 
>> On 31.03.2016 21:21, David Miller wrote:
>> >From: Daniel Borkmann <daniel@iogearbox.net>
>> >Date: Thu, 31 Mar 2016 14:16:18 +0200
>> >
>> >Alexei, do you really mind if I apply Danile's patch?
> 
> I don't have strong opinion either way.
> Though Hannes's patch below looks simpler and easier to backport.
> Yeah, I do care about backports quite a bit more nowadays :)

You know, I care a lot about backports too :)

But Hannes's patch has the same fundamental issue, I think.

If we accept both synchornization styles, false positives are more
likely.

And in the long term, we can fix the false positive possibilities with
the RTNL checks.
