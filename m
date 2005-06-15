From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TCP prequeue performance
Date: Wed, 15 Jun 2005 16:41:15 -0700 (PDT)
Message-ID: <20050615.164115.74747690.davem@davemloft.net>
References: <BED5FA3B.2A0%cndougla@purdue.edu>
	<m1br679otj.fsf@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cndougla@purdue.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261666AbVFOXlh@vger.kernel.org>
To: ak@muc.de
In-Reply-To: <m1br679otj.fsf@muc.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Subject: Re: TCP prequeue performance
Date: Thu, 16 Jun 2005 01:34:48 +0200

> Chase Douglas <cndougla@purdue.edu> writes:
> >
> > I then disabled the prequeue mechanism by changing net/ipv4/tcp.c:1347 of
> > 2.6.11:
> >
> > if (tp->ucopy.task == user_recv) {
> >     to
> > if (0 && tp->ucopy.task == user_recv) {
> 
> You actually didn't disable it completely - it would still be filled. 

Not true, if this check does not pass, tp->ucopy.task is
never set, therefore prequeue processing is never performed.

This test must pass the first time, when both tp->ucopy.task
and user_recv are both NULL, in order for prequeue processing
to occur at all.

So his change did totally disable prequeue.
