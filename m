From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netem: fix loss generators
Date: Thu, 28 Nov 2013 18:18:13 -0500 (EST)
Message-ID: <20131128.181813.1984270468860720177.davem@davemloft.net>
References: <20131121175419.59059598@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefano.salsano@uniroma2.it, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3K1XSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:18:14 -0500
In-Reply-To: <20131121175419.59059598@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 21 Nov 2013 17:54:19 -0800

> Patch from developers of the alternative loss models, downloaded from:
>    http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG
> 
> We found some bugs in our first implementation.
> A first set of bugs is in the function loss_4state:
>    In the case 1 of the switch statement in the if conditions we
>     need to add clg->a4 to clg->a1, according to the model.
>    In the case 3 of the switch statement we need to delete "return
>     true" if the condition leads us in the state 1, because the state 1 is
>     a good state.
> 
> A second set of bugs is in the function loss_gilb_ell
>   In both cases of the switch statement we need to add the break
>     statement, because the two cases are mutually exclusive.
>   In the case 2, of the switch we change the direction of the inequality to
>     net_random()>clg->a3, because clg->a3 is h in the GE model and when h
>     is 0 all packets will be lost.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Stephen, can you adjust this patch to take into account commit:

4a3ad7b3eade08ad1c760aaa4fe06a36f2584939

as Hagen noted?

Thank you.
