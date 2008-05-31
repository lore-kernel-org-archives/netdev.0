From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 08:09:47 +0200
Message-ID: <20080531060947.GA26441@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:37973 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbYEaGKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2008 02:10:10 -0400
Content-Disposition: inline
In-Reply-To: <20080530181839.GA31915@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> ah, in retrospect i realized that this test had one flaw: some of the 
> systems i the build cluster already ran a newer kernel and hence were 
> targets for this bug.
> 
> so i turned off CONFIG_TCP_CONG_CUBIC on all the testboxes and 
> rebooted the cluster boxes into 2.6.25, and the hung sockets are now 
> gone. (about 150 successful iterations)
> 
> i did another change as well: i removed the localhost distcc 
> component. I'll reinstate that now to make sure it's really related to 
> TCP_CONG_CUBIC and not to localhost networking.

ok, once i added back the localhost distcc component and the hung kernel 
build + stuck TCP socket bug happened again overnight:

 Active Internet connections (w/o servers)
 Proto Recv-Q Send-Q Local Address               Foreign Address             State
 tcp    72187      0 10.0.1.14:3632              10.0.1.14:47910             ESTABLISHED
 tcp        0 174464 10.0.1.14:47910             10.0.1.14:3632              ESTABLISHED

so it seems distcc over localhost was the aspect that made it fail.

_Perhaps_ what matters is to have the new post-rc3 TCP code on _both_ 
sides of the connection. But that is just a theory - it could be timing, 
etc.

	Ingo
