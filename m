From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic:
 swapper/0x10000100/0
Date: Fri, 09 Feb 2007 15:31:54 -0800
Message-ID: <1171063915.3304.1.camel@rh4>
References: <200702091623.l19GNiUP006513@fire-2.osdl.org>
 <20070209133802.01286bbb.akpm@linux-foundation.org>
 <20070209223520.GA27634@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	lpiccilli@gelre.com.br,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2253 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423345AbXBIWs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 17:48:27 -0500
In-Reply-To: <20070209223520.GA27634@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-02-09 at 23:35 +0100, Francois Romieu wrote:
> Andrew Morton <akpm@linux-foundation.org> :
> > 
> > cond_resched() called from softirq, amongst other problems.
> 
> Seems too simple to be right. Btw calling dev_set_mac_address
> may hurt some tg3:
> 
> -> tg3_set_mac_addr
>    -> tg3_netif_stop (depending on the content of their sram): 
>       -> netif_poll_disable
>          -> schedule_timeout_interruptible
> 

Yes, known problem.  Bonding calls dev_set_mac_address from unsleepable
context.

