From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] e100: Fix workqueue race
Date: Thu, 21 Jan 2010 09:20:35 -0800
Message-ID: <20100121092035.6c4d398d@nehalam>
References: <20100121164801.416170b9@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46313 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754171Ab0AURUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 12:20:46 -0500
In-Reply-To: <20100121164801.416170b9@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jan 2010 16:48:01 +0000
Alan Cox <alan@linux.intel.com> wrote:

> (Incidentally this doesn't seem to be the only net driver that looks
> suspect here)
> 
> e100: Fix the TX workqueue race
> 
> From: Alan Cox <alan@linux.intel.com>
> 
> Nothing stops the workqueue being left to run in parallel with close or a
> few other operations. This causes double unmaps and the like.
> 
> See kerneloops.org #1041230 for an example
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Most drivers solve this by getting rtnl_lock in the timeout work
function.

-- 
