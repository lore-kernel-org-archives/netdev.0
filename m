From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net V2] bonding:force to use primary slave
Date: Mon, 11 Jun 2012 22:00:47 -0700
Message-ID: <7128.1339477247@death.nxdomain>
References: <32118.1339449441@death.nxdomain> <0d639c5449aad0222c7e88cf8a61013c1cdf98e2.1339472044.git.wpan@redhat.com>
Cc: netdev@vger.kernel.org, nicolas.2p.debian@gmail.com
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:35832 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab2FLFBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 01:01:17 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 11 Jun 2012 23:01:16 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 534CDC90063
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 01:00:48 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5C50mXp129694
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 01:00:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5C50mSl014047
	for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 01:00:48 -0400
In-reply-to: <0d639c5449aad0222c7e88cf8a61013c1cdf98e2.1339472044.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Weiping Pan <wpan@redhat.com> wrote:

>When we set primary slave with module parameters, bond will always use this
>primary slave as active slave.
>
>But when we modify primary slave via sysfs, it will call
>bond_should_change_active() and take into account primary_reselect.
>
>And I think we should use the new primary slave as the new active slave
>regardless of the value of primary_reselect, since primary slave really should
>have priority than other slaves.

	The whole point of primary_reselect is that the primary slave
does not have priority unless it meets the reselect criteria, or it is
being enslaved.

>primary_reselect is introduced to handle the failure or recovery of primary
>slave, but when we modify primary slave via sysfs, we want to give it higher
>priority, and it may or may not be a failure or recovery slave.
>
>Thus the behavior is the same with module parameters and meets the
>administrator's expectation.

	I still disagree with this patch.  My comments regarding the
prior version were intended to mean that we should document the current
behavior, not change the behavior and document the new behavior.

	If an administrator wishes for the newly set primary to
immediately become the active slave, they can either leave
primary_reselect at its default setting or utilize the available
mechanism to change the active slave.  Applying this patch eliminates
the ability to alter the primary slave setting without simultaneously
changing the active slave.

	Further, the default value for primary_reselect already does
this (change to the new primary immediately); this patch only affects
the case that primary_reselect is set to a non-default value. In my
mind, this reinforces that the current behavior is correct, and that the
primary_reselect setting should apply to the newly selected primary
(because the administrator has explicitly chosen that behavior).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
