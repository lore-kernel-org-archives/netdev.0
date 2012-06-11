From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] iproute2: Improve list add.
Date: Mon, 11 Jun 2012 15:01:07 -0700
Message-ID: <20120611150107.41260615@nehalam.linuxnetplumber.net>
References: <1337726239-9925-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jpettit@nicira.com, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55424 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206Ab2FKWBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 18:01:09 -0400
In-Reply-To: <1337726239-9925-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 May 2012 15:37:19 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> ip command reads entire list of devices on every flush command.
> While adding device record to list is does list traversal O(n).
> This is time consuming for large batch commands.
> Following patch improves list add operation to O(1).
> 
> Reported-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  ip/ipaddress.c |   16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 

This no longer applies, after a similar patch I just accepted
from Eric.

commit 62e2e540919d31147165dabd35431c0649122c96
Author: Eric Dumazet <edumazet@google.com>
Date:   Sat Jun 9 13:55:55 2012 +0200

    ip: speedup ip link
    
    ip link has quadratic behavior because store_nlmsg()
    has a head list pointer and search the end of list.
    
    Provides a head/tail to cut time.
    
    Time with 128000 net devices, to do "ip link show dev xxx"
    
    Before: 2m3.594s
    After: 0m2.830s
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>


If that doesn't fix your problem go ahead and resubmit.
