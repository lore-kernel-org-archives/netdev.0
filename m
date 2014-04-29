From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: problem forwarding IP fragments with DF bit set (caused by
 ipv4: fix path MTU discovery with connection tracking)
Date: Tue, 29 Apr 2014 08:37:21 -0700
Message-ID: <1398785841.29914.146.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398703056.12635.41.camel@sakura.staff.proxad.net>
	 <20140429143324.GB12781@macbook.localnet>
	 <1398782535.4033.11.camel@sakura.staff.proxad.net>
	 <20140429144513.GA12969@macbook.localnet>
	 <1398785021.4033.19.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:50607 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757420AbaD2PhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 11:37:22 -0400
Received: by mail-pa0-f41.google.com with SMTP id kp14so389670pab.0
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 08:37:16 -0700 (PDT)
In-Reply-To: <1398785021.4033.19.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-29 at 17:23 +0200, Maxime Bizon wrote:
> On Tue, 2014-04-29 at 15:45 +0100, Patrick McHardy wrote:
> 
> > Right, that is not correct of course. We save the original packet size
> > and should either refragment to that size or send an ICMP frag required
> > if the original size exceeds the outgoing MTU.
> 
> yep indeed, if any fragment is bigger than outgoing MTU
> 
> > So your patch does look correct, however we should probably only set
> > local_df in conntrack defrag.
> 
> I thought of putting it in conntrack code first, but I had some doubts.
> There are a lot of possible paths that can be taken after reassembly
> (ipsec, tunnel, ...), and I did not audit all of them.
> 
> Since the patch that caused this regression modified the generic
> fragmentation code, it may have caused other silent breakage.
> 
> Eric/David, could I get your feeling about this ?

Hmm... maybe its finally time to rename local_df to ignore_df, as
Maze suggested some time ago ...
