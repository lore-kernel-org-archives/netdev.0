From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 00:12:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805301436260.16829@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu>
 <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu>
 <20080529130823.GA8364@elte.hu> <20080530110904.GA14184@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53199 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbYE3VRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 17:17:46 -0400
In-Reply-To: <20080530110904.GA14184@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 May 2008, Ingo Molnar wrote:

> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > btw., i now also have a hung socket over real network:
> 
> last night i turned off distcc support, and got about 200 successful 
> bootups and zero TCP hangs (as expected - there's not much TCP traffic 
> if the distcc cluster is not utilized).
> 
> but that's 200 overnight tests instead of the expected 600, so this is a 
> major and rather crippling bug to me.
> 
> There's no good way to detect these hung sockets by me from userspace 
> and get rid of them. Has anyone before thought of the obvious: to write 
> a kernel-space "TCP socket watchdog" kernel feature that detects them 
> and tries to free them so that people can become aware of it?
>
> Hung sockets is a re-occuring bug in the TCP stack after all. (and it's 
> a natural property of it: state machine designs are always vulnerable to 
> lost event problems.)

...It is quite easy to kill a TCP flow with enough information (seqnos 
which one could collect e.g., from a tcpdump), just a RST is necessary,
so user-space could do that too.

-- 
 i.
