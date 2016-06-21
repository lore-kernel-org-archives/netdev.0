From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH] mpls: Add missing RCU-bh read side critical section
 locking in output path
Date: Tue, 21 Jun 2016 16:15:35 +0100
Message-ID: <79fc57ce-b43c-46f9-89cc-f45b1b954519@brocade.com>
References: <20160620180527.GU20238@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Lennert Buytenhek <buytenh@wantstofly.org>,
	<netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:50494 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139AbcFUPP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:15:57 -0400
In-Reply-To: <20160620180527.GU20238@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/06/16 19:05, Lennert Buytenhek wrote:
> From: David Barroso <dbarroso@fastly.com>
>
> When locally originated IP traffic hits a route that says to push
> MPLS labels, we'll get a call chain dst_output() -> lwtunnel_output()
> -> mpls_output() -> neigh_xmit() -> ___neigh_lookup_noref() where the
> last function in this chain accesses a RCU-bh protected struct
> neigh_table pointer without us ever having declared an RCU-bh read
> side critical section.
>
> As in case of locally originated IP traffic we'll be running in process
> context, with softirqs enabled, we can be preempted by a softirq at any
> time, and RCU-bh considers the completion of a softirq as signaling
> the end of any pending read-side critical sections, so if we do get a
> softirq here, we can end up with an unexpected RCU grace period and
> all the nastiness that that comes with.
>
> This patch makes neigh_xmit() take rcu_read_{,un}lock_bh() around the
> code that expects to be treated as an RCU-bh read side critical section.
>
> Signed-off-by: David Barroso <dbarroso@fastly.com>
> Signed-off-by: Lennert Buytenhek <lbuytenhek@fastly.com>

LGTM too.

Acked-by: Robert Shearman <rshearma@brocade.com>
