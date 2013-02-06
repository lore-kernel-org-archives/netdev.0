From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Wed, 06 Feb 2013 05:48:24 -0800
Message-ID: <51125F28.4000409@intel.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com> <loom.20130204T174808-896@post.gmane.org> <CAHrpEqSXhEBQpnR60mjP67gbVWNemfa3tTuoDTKipej_6QQ62g@mail.gmail.com> <loom.20130205T111507-687@post.gmane.org> <CAHrpEqTsUjWjxY3_C4kGL_S0pgpYawgBaSip3DEnZd3CY1hn0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jim Baxter <jim_baxter@mentor.com>, netdev@vger.kernel.org
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8837 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032Ab3BFNs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 08:48:26 -0500
In-Reply-To: <CAHrpEqTsUjWjxY3_C4kGL_S0pgpYawgBaSip3DEnZd3CY1hn0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/2013 1:50 AM, Frank Li wrote:
>
> It is not easy to fix. Need put tx to NAPI poll function.
> I will work on that after China New year holiday

Converting Tx to NAPI is the best solution, but you can put a temporary 
fix in.  Don't take a spin_lock() in fec_enet_tx(), rather take a 
spin_lock_irqsave() since you're still in HARDIRQ context.

-PJ
