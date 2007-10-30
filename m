From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 1/1][NETNS] resend:  fix net released by rcu callback
Date: Tue, 30 Oct 2007 16:34:29 -0600
Message-ID: <m1sl3sjkp6.fsf@ebiederm.dsl.xmission.com>
References: <20071030162139.954791193@mai.toulouse-stg.fr.ibm.com>
	<20071030162305.458123510@mai.toulouse-stg.fr.ibm.com>
	<m1odegl47t.fsf@ebiederm.dsl.xmission.com> <4727A57E.501@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:44188 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755541AbXJ3WfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 18:35:19 -0400
In-Reply-To: <4727A57E.501@fr.ibm.com> (Daniel Lezcano's message of "Tue, 30
	Oct 2007 22:43:26 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> Yes, I had this problem when doing ipv6 isolation for netns49. The ipv6
> subsystem creation failed and the different subsystem where rollbacked in the
> setup_net function.
> When the network namespace was about to be freed in free_net function, I had the
> error with an usage refcount different from zero.
> It appears that was coming from core/neighbour.c
>
> neigh_parms_release
>  -> neigh_rcu_free_parms
>    -> neigh_parms_put
>      -> neigh_parms_destroy
>        -> release_net
>
> The free_net function was called before rcu callback neigh_rcu_free_parms.

Ok. Cool.  It is good to know that this patch was tested.  These kinds
of subtle fixes are always more solid when you can actually test them.

Eric
