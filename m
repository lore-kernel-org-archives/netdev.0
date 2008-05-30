From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Fri, 30 May 2008 13:09:04 +0200
Message-ID: <20080530110904.GA14184@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu> <20080529130823.GA8364@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:45355 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753613AbYE3LJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 07:09:34 -0400
Content-Disposition: inline
In-Reply-To: <20080529130823.GA8364@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> btw., i now also have a hung socket over real network:

last night i turned off distcc support, and got about 200 successful 
bootups and zero TCP hangs (as expected - there's not much TCP traffic 
if the distcc cluster is not utilized).

but that's 200 overnight tests instead of the expected 600, so this is a 
major and rather crippling bug to me.

There's no good way to detect these hung sockets by me from userspace 
and get rid of them. Has anyone before thought of the obvious: to write 
a kernel-space "TCP socket watchdog" kernel feature that detects them 
and tries to free them so that people can become aware of it?

Hung sockets is a re-occuring bug in the TCP stack after all. (and it's 
a natural property of it: state machine designs are always vulnerable to 
lost event problems.)

	Ingo
