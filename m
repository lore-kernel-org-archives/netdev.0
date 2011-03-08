From: Injong Rhee <rhee@ncsu.edu>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 08 Mar 2011 10:26:36 -0500
Message-ID: <4D764AAC.30302@ncsu.edu>
References: <20110308093215.GA23842@xanadu.blop.info> <il4vur$3ka$1@dough.gmane.org> <20110308111011.GA27967@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: WANG Cong <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:33794 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756060Ab1CHP0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 10:26:39 -0500
In-Reply-To: <20110308111011.GA27967@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for updating CUBIC hystart. You might want to test the
cases with more background traffic and verify whether this
threshold is too conservative.

On 3/8/11 6:10 AM, Lucas Nussbaum wrote:
> CUBIC Hystart uses two heuristics to exit slow start earlier, before
> losses start to occur. Unfortunately, it tends to exit slow start far
> too early, causing poor performance since convergence to the optimal
> cwnd is then very slow. This was reported in
> http://permalink.gmane.org/gmane.linux.network/188169 and
> https://partner-bugzilla.redhat.com/show_bug.cgi?id=616985
>
> I am using an experimental testbed (http://www.grid5000.fr/) with two
> machines connected using Gigabit ethernet to a dedicated 10-Gb backbone.
> RTT between both machines is 11.3ms. Using TCP CUBIC without Hystart,
> cwnd grows to ~2200.  With Hystart enabled, CUBIC exits slow start with
> cwnd lower than 100, and often lower than 20, which leads to the poor
> performance that I reported.
>
> After instrumenting TCP CUBIC, I found out that the segment-to-ack RTT
> tends to vary quite a lot even when the network is not congested, due to
> several factors including the fact that TCP sends packet in burst (so
> the packets are queued locally before being sent, increasing their RTT),
> and delayed ACKs on the destination host.
>
> The patch below increases the thresholds used by the two Hystart
> heuristics. First, the length of an ACK train needs to reach 2*minRTT.
> Second, the max RTT of a group of packets also needs to reach 2*minRTT.
> In my setup, this causes Hystart to exit slow start when cwnd is in the
> 1900-2000 range using the ACK train heuristics, and sometimes to exit in
> the 700-900 range using the delay increase heuristic, dramatically
> improving performance.
>
> I could provide access to my testbed if someone wants to do further
> experiments.
>
> Signed-off-by: Lucas Nussbaum<lucas.nussbaum@loria.fr>

