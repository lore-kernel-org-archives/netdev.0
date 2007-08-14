From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Problem with semantics?
Date: 14 Aug 2007 02:38:13 +0200
Message-ID: <p737inzne6i.fsf@bingen.suse.de>
References: <OFF8FEF8BA.07073375-ONC2257336.005DB73A-C2257336.005E19ED@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, mtk-manpages@gmx.net
To: Shay Goikhman <GOIKHMAN@il.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:48481 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761503AbXHMXoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 19:44:04 -0400
In-Reply-To: <OFF8FEF8BA.07073375-ONC2257336.005DB73A-C2257336.005E19ED@il.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shay Goikhman <GOIKHMAN@il.ibm.com> writes:

> Dear Linux maintainers,
> 
>  I'm doing :
> 
>       setsockopt(s,  SO_RCVTIMEO, t1 );                  // set time-out
> t1 on socket while block receiving on it
>       select(,,, &fd_set_including(s), .., &errs, t2);      // block till
> receive or time-out  t 2 jointly on a set of sockets
> 
> Apparently, I could no find reference on the coupled behavior of the two
> above statements in Linux documentation.
> As I understand the blocking semantics, I would expect  that  if t1<t2 ,
> select should return after t1 with the descriptor 's' in 'errs' if 's' does
> not become readable in the t1 interval.
> 
> It is not so in life -- select ignores t1 altogether.
> 
> Do you have some enlightening knowledge on the matter?

RCVTIMEO only applies to recvmsg et.al., similar to SNDTIMEO only
apply to sendmsg etc. But select/poll only report events, they
do not actually send or receive by themselves.

Michael, perhaps you can clarify that in the manpages

-Andi
