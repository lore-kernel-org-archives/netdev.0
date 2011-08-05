From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: [PATCH 1/3] net: sendmmsg should only return an error if no
 messages were sent
Date: Fri, 05 Aug 2011 09:20:08 +0100
Message-ID: <1312532408.2762.4.camel@menhir>
References: <20110805000737.743684961@samba.org>
	 <20110805000822.240895823@samba.org>
	 <201108050357.p753vtpO022773@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, rdenis@simphalempin.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850Ab1HEIR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 04:17:59 -0400
In-Reply-To: <201108050357.p753vtpO022773@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2011-08-05 at 12:57 +0900, Tetsuo Handa wrote:
> Anton Blanchard wrote:
> > sendmmsg uses a similar error return strategy as recvmmsg but it
> > turns out to be a confusing way to communicate errors.
> > 
> > The current code stores the error code away and returns it on the next
> > sendmmsg call. This means a call with completely valid arguments could
> > get an error from a previous call.
> > 
> > Change things so we only return an error if no datagrams could be sent.
> > If less than the requested number of messages were sent, the application
> > must retry starting at the first failed one and if the problem is
> > persistent the error will be returned.
> > 
> > This matches the behaviour of other syscalls like read/write - it
> > is not an error if less than the requested number of elements are sent.
> 
> OK. David S. Miller suggested this behavior and Anton Blanchard agreed with
> this behavior.
> 
> Quoting from commit a2e27255 "net: Introduce recvmmsg socket syscall":
> | . R?mi Denis-Courmont & Steven Whitehouse: If we receive N < vlen
> |   datagrams and then recvmsg returns an error, recvmmsg will return
> |   the successfully received datagrams, store the error and return it
> |   in the next call.
> 
> R?mi Denis-Courmont, Steven Whitehouse and Arnaldo Carvalho de Melo, do you
> want to change recvmmsg()'s behaviour as well?

Since I've joined this part way through it seems, I'm assuming that if
something was sent/received then that will be returned and the error
stored until the next call. If nothing was sent/received then the error
can be returned immediately.

That is what I'd expect to be the case, since otherwise it is impossible
to know how much has been successfully sent/received in the partial
failure case, I think. Also it means that sendmmesg/recvmmsg matches
sendmsg/recvmsg in terms of expected return values and thus the
principle of least surprise.

So if thats what is being proposed, then it sounds good to me,

Steve.


