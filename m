From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH V3 5/8] sctp: use limited socket backlog
Date: Fri, 05 Mar 2010 08:30:01 -0500
Message-ID: <4B910759.6010505@hp.com>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>	 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>	 <1267761707-15605-4-git-send-email-yi.zhu@intel.com>	 <1267761707-15605-5-git-send-email-yi.zhu@intel.com> <1267770483.2867.6.camel@edumazet-laptop> <DA586906BA1FFC4384FCFD6429ECE860A4604767@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sridhar Samudrala <sri@us.ibm.com>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:13227 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab0CENaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 08:30:05 -0500
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860A4604767@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Zhu, Yi wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> As advertized by comment, we should hold the association *before*
>> accessing backlog queue.
> 
>> If order is not important, comment should be relaxed somehow ?
> 
> I don't see how the order is important here. We are under sock_lock 
> here thus nobody will race with us. IMHO, the comment talks about
> if a packet is queued into the backlog, we need to increase the assoc/ep
> reference count. Otherwise the assoc/ep might be disappeared when
> we are about to process it (by sctp_backlog_rcv) sometime later.
> 
> Thanks,
> -yi

Yes, that's correct.  The order is not really important since we
are under lock and are actually already holding a ref.  However
the ref will be dropped once we exit the function, so the function
takes an additional ref that is held while the packet is backloged.

You could get rid of the extra nesting though by returning early
if backlog failed.

-vlad
