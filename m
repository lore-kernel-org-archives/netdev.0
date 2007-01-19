From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH 10/12] forcedeth: tx max work
Date: Fri, 19 Jan 2007 11:27:02 -0500
Message-ID: <45B0F156.4050504@nvidia.com>
References: <45A3DF43.8030301@nvidia.com> <45B03271.5080802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:10172 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964932AbXASWCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jan 2007 17:02:22 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45B03271.5080802@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Ayaz Abdulla wrote:
>  > This patch adds a limit to how much tx work can be done in each
>  > iteration of tx processing.
>  >
>  > Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> What about the "tail end" of the work, when the limit is reached?
> 
> Remember that delaying the completion of TX's too long increases latency.
> 
> It seems to me that this patch needs a timer or somesuch, to guarantee
> that TX completions are not delayed too long in the worst case.

Yes, you are right.
There is a timer interrupt that fires in throughput mode every 10ms (in 
cpu mode it fires at approx every 130us). I can use that to clean out 
any uncompleted TXs. Let me know if 10ms is not too late for worst case 
tx completion.

> 
>         Jeff
> 
> 
> 
