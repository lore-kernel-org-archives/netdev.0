From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp_cubic: enable TCP timestamps
Date: Tue, 8 Mar 2011 10:42:11 -0800
Message-ID: <20110308104211.3567526f@nehalam>
References: <20110308080926.GA22641@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sangtae Ha <sha2@ncsu.edu>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46870 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753889Ab1CHSmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 13:42:13 -0500
In-Reply-To: <20110308080926.GA22641@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Mar 2011 09:09:26 +0100
Lucas Nussbaum <lucas.nussbaum@loria.fr> wrote:

> The Hystart slow start algorithm requires precise RTT delay measurements
> to decide when to leave slow start. However, currently, CUBIC doesn't
> enable TCP timestamps. This can cause Hystart to mis-estimate the RTT,
> and to leave slow start too early, generating bad performance since
> convergence to the optimal cwnd is slower.
> 
> Timestamps are already used by TCP Illinois, LP, Vegas, Veno and Yeah.
> 
> Signed-off-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>

Just to explain what RTT_STAMP does. It causes the tcp receive code
to compute the rtt using high resolution clocks rather than just
jiffies. It requires access to ktime_get_real which means accessing
clock source. This is cheap for TSC, a little expensive for HPET but
expensive for PIT. I worry that enabling it may hurt regular users
on old desktops.  But without it enabling RTT_STAMP, packets that
get acked in less than a jiffie (1 - 10 ms) will 

Also I should have used ktime_get rather than ktime_get_real
because real time is altered by NTP and other actions.
