From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Fri, 30 May 2008 20:18:39 +0200
Message-ID: <20080530181839.GA31915@elte.hu>
References: <20080526115628.GA31316@elte.hu> <20080529084524.GA24892@elte.hu> <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi> <20080529112257.GA18130@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:47716 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752403AbYE3STE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:19:04 -0400
Content-Disposition: inline
In-Reply-To: <20080529112257.GA18130@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> after about 50 bootups i got a hung test again:
> 
> titan:~/tip> netstat -nt
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address               Foreign Address             
> State
> tcp        0      0 10.0.1.14:22                10.0.1.16:58062  ESTABLISHED
> tcp        0      0 10.0.1.14:22                10.0.1.16:60109  ESTABLISHED
> tcp        0  86368 10.0.1.14:43914             10.0.1.16:3632   ESTABLISHED
> 
> and this time with CUBIC_TCP disabled - so that was a red herring.

ah, in retrospect i realized that this test had one flaw: some of the 
systems i the build cluster already ran a newer kernel and hence were 
targets for this bug.

so i turned off CONFIG_TCP_CONG_CUBIC on all the testboxes and rebooted 
the cluster boxes into 2.6.25, and the hung sockets are now gone. (about 
150 successful iterations)

i did another change as well: i removed the localhost distcc component. 
I'll reinstate that now to make sure it's really related to 
TCP_CONG_CUBIC and not to localhost networking.

	Ingo
