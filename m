From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: llc: fix order of evaluation in
 llc_conn_ac_inc_vr_by_1
Date: Wed, 01 Jan 2014 22:23:23 -0500 (EST)
Message-ID: <20140101.222323.688931116639418849.davem@davemloft.net>
References: <1388613865-25003-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net,
	stephen@networkplumber.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaABDXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:23:25 -0500
In-Reply-To: <1388613865-25003-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  1 Jan 2014 23:04:25 +0100

> Function llc_conn_ac_inc_vr_by_1() evaluates via macro
> PDU_GET_NEXT_Vr() into ...
> 
>   llc_sk(sk)->vR = ++llc_sk(sk)->vR & 0xffffffffffffff7f
> 
> ... but the order in which the side effects take place is
> undefined because there is no intervening sequence point.
> 
> As llc_sk(sk)->vR is written in llc_sk(sk)->vR (assignment
> left-hand side) and written in ++llc_sk(sk)->vR & 0xffffffffffffff7f
> this might possibly yield undefined behavior.
> 
> The final value of llc_sk(sk)->vR is ambiguous, because,
> depending on the order of expression evaluation, the
> increment may occur before, after, or interleaved with
> the assignment. In C, evaluating such an expression yields
> undefined behavior.
> 
> Since we're doing the increment via PDU_GET_NEXT_Vr() macro
> and the only place it is being used is from
> llc_conn_ac_inc_vr_by_1(), in order to increment vR by 1
> with a follow-up optimized modulo, rewrite the expression
> into ((vR + 1) & CONST) in order to fix this.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
