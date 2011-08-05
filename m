From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 1/3] net: sendmmsg should only return an error if no messages were sent
Date: Fri, 05 Aug 2011 12:57:55 +0900
Message-ID: <201108050357.p753vtpO022773@www262.sakura.ne.jp>
References: <20110805000737.743684961@samba.org> <20110805000822.240895823@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@redhat.com, rdenis@simphalempin.com, swhiteho@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:63028 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab1HED6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 23:58:00 -0400
In-Reply-To: <20110805000822.240895823@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Blanchard wrote:
> sendmmsg uses a similar error return strategy as recvmmsg but it
> turns out to be a confusing way to communicate errors.
> 
> The current code stores the error code away and returns it on the next
> sendmmsg call. This means a call with completely valid arguments could
> get an error from a previous call.
> 
> Change things so we only return an error if no datagrams could be sent.
> If less than the requested number of messages were sent, the application
> must retry starting at the first failed one and if the problem is
> persistent the error will be returned.
> 
> This matches the behaviour of other syscalls like read/write - it
> is not an error if less than the requested number of elements are sent.

OK. David S. Miller suggested this behavior and Anton Blanchard agreed with
this behavior.

Quoting from commit a2e27255 "net: Introduce recvmmsg socket syscall":
| . R?mi Denis-Courmont & Steven Whitehouse: If we receive N < vlen
|   datagrams and then recvmsg returns an error, recvmmsg will return
|   the successfully received datagrams, store the error and return it
|   in the next call.

R?mi Denis-Courmont, Steven Whitehouse and Arnaldo Carvalho de Melo, do you
want to change recvmmsg()'s behaviour as well?
