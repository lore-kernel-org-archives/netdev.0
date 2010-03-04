From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing
 control.
Date: Thu, 4 Mar 2010 23:55:14 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003042352220.27392@obet.zrqbmnf.qr>
References: <4B894564.7080104@parallels.com> <m1iq9io5sc.fsf@fess.ebiederm.org> <4B89727C.9040602@parallels.com> <m1ljeempk6.fsf@fess.ebiederm.org> <4B8AE8C1.1030305@free.fr> <4B8D28CF.8060304@parallels.com> <20100302211942.GA17816@us.ibm.com>
 <m1y6iaqsmm.fsf@fess.ebiederm.org> <20100303000743.GA13744@us.ibm.com> <m1ocj6qljj.fsf@fess.ebiederm.org> <20100303153800.GA937@us.ibm.com> <m13a0hmblr.fsf@fess.ebiederm.org> <m1pr3j92x8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:46800 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207Ab0CDWzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 17:55:17 -0500
In-Reply-To: <m1pr3j92x8.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2010-03-04 22:45, Eric W. Biederman wrote:
>
>So an unshare of the pid namespace that doesn't really take effect
>until we fork may actually be usable from pam, and in fact is probably
>the preferred implementation.  It looks like neither openssh nor login
>from util-linux-ng will cope properly with getting any pid back from
>wait() except the pid of their child.

Correct; I can tell from experience with pam_mount. GDM for example is 
very unhappy if you fork/exit processes in PAM modules and don't hide 
the fact by bending SIGCHLD from gdm_handler to mypam_handler (which 
itself is racy, suppose GDM re-set the SIGCHLD handler midway through).

(In this particular case however, I'd prefer if login programs like GDM 
just ignored any PIDs they did not spawn in the first place instead of 
moaning around.)
