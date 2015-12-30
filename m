From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] sctp: use transport hashtable to replace
 association's with rhashtable
Date: Wed, 30 Dec 2015 14:11:20 -0500
Message-ID: <1451502680.8255.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
	 <1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151230173202.GB16270@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org, mleitner@redhat.com,
	vyasevic@redhat.com, daniel@iogearbox.net, davem@davemloft.net
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34212 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbL3TLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 14:11:22 -0500
In-Reply-To: <20151230173202.GB16270@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-30 at 15:32 -0200, Marcelo Ricardo Leitner wrote:
> On Wed, Dec 30, 2015 at 12:19:39PM -0500, Eric Dumazet wrote:
> > On Wed, 2015-12-30 at 23:50 +0800, Xin Long wrote:
> > 
> > > besides, this patchset will use transport hashtable to replace
> > > association hashtable to lookup with rhashtable api. get transport
> > > first then get association by t->asoc. and also it will make tcp
> > > style work better.
> > 
> > SCTP already has a hash table, why not simply changing the way items are
> > hashed into it ?
> 
> Because Vlad asked to split the patch so it gets easier to review. The
> direct change was quite big.
> 
> > Sure, storing thousands of sockets in a single hash bucket is not wise.
> > 
> > Switching SCTP to rhashtable at this moment is premature, it is still
> > moving fast.
> 
> Dave and Vlad had asked in the first review for considering using
> rhashtable (ok, Dave didn't mention it by name).  We did, and it seemed
> nice beside 1 issue Xin found, regarding multiple rehashing, which I'll
> highlight in a reply right away. 
> Said all this, I know this was your second email already against this
> usage, but I have to ask, sorry: still really against it?

Well, it seems that Dave is OK to fix all remaining bugs in rhashtable.

I was not aware that 'we' decided to force rhashtable all over the
places, because it looks so sexy and fun.

Let see how funny it will be then.
