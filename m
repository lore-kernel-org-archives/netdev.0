From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/9] ipv4: remove static flush_delay variable
Date: Mon, 07 Jul 2008 01:43:06 -0700
Message-ID: <m1k5fyytid.fsf@frodo.ebiederm.org>
References: <1215177360.27873.50.camel@iris.sw.ru>
	<1215177432-25934-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45709 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbYGGIvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 04:51:48 -0400
In-Reply-To: <1215177432-25934-3-git-send-email-den@openvz.org> (Denis
	V. Lunev's message of "Fri, 4 Jul 2008 17:17:06 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Denis V. Lunev" <den@openvz.org> writes:

> flush delay is used as an external storage for net.ipv4.route.flush sysctl
> entry. It is write-only.
>
> The ctl_table->data for this entry is used once. Fix this case to point
> to the stack to remove global variable. Do this to avoid additional
> variable on struct net in the next patch.
>
> Possible race (as it was before) accessing this local variable is removed
> using flush_mutex.

FYI.  You can avoid the locking entirely by defining a local struct ctl_table variable
on the stack.

Eric
