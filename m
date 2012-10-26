From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] qfq: handle the case that front slot is
 empty
Date: Fri, 26 Oct 2012 10:10:07 +0200
Message-ID: <1351239007.6537.291.camel@edumazet-glaptop>
References: <1350965711-4390-1-git-send-email-amwang@redhat.com>
	 <F36C0EC1-0A4C-48FB-ABF3-A89575A9287E@unimore.it>
	 <1350982432.26308.8.camel@cr0>
	 <58DEB62C-6237-435E-8300-8E390F101F58@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Paolo Valente <paolo.valente@unimore.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59862 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757232Ab2JZIKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:10:10 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1129186bkc.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 01:10:09 -0700 (PDT)
In-Reply-To: <58DEB62C-6237-435E-8300-8E390F101F58@unimore.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 09:51 +0200, Paolo Valente wrote:

> I think I will ask for your help soon, thanks.
> 
> The cause of the failure is TCP segment offloading, which lets qfq
> receive packets with a much larger size than the MTU of the device.
> In this respect, under qfq the default max packet size lmax for each
> class (2KB) is only slightly higher than the MTU. Violating the lmax
> constraint causes the corruption of the data structure that implements
> the bucket lists of the groups. In fact, the failure that you found is
> only one of the consequences of this corruption. I am sorry I did not
> discover it before, but, foolishly, I have run only UDP tests.
> 
> I am thinking about the best ways for addressing this issue.
> 
> BTW, I think that the behavior of all the other schedulers should be
> checked as well. For example, with segment offloading, drr must
> increment the deficit of a class for at most (64K/quantum) times,
> i.e., rounds, before it can serve the next packet of the class. The
> number of instructions per packet dequeue becomes therefore
> (64K/quantum) times higher than without segment offloading.
> 

OK, good to know you found the problem.

Normally, TSO is supported by other qdisc, maybe not optimally but
supported.

For example, one known problem with TSO is that skb->len is a
underestimation of real number of bytes sent on wire

If MSS is a bit small, TBF/HTB/CBQ can really overdrive links.

We probably should have a more precise estimation.
