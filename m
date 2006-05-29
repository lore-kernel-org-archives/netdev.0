From: jamal <hadi@cyberus.ca>
Subject: Re: Refactor Netlink connector?
Date: Mon, 29 May 2006 08:11:26 -0400
Message-ID: <1148904686.27078.20.camel@jzny2>
References: <Pine.LNX.4.64.0605271223390.12872@d.namei>
	 <Pine.LNX.4.64.0605271303050.13104@d.namei>
	 <20060528153321.GB31822@2ka.mipt.ru>
	 <20060528.233649.22498001.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sds@tycho.nsa.gov, tgraf@suug.ch, netdev@vger.kernel.org,
	jmorris@namei.org, johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:34983 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750716AbWE2MLe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 May 2006 08:11:34 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fkgau-0000P5-8w
	for netdev@vger.kernel.org; Mon, 29 May 2006 08:11:36 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060528.233649.22498001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-28-05 at 23:36 -0700, David Miller wrote:
[..]
> 
> More to the point I think that none of this will be handled
> transparently unless the onus is put on new netlink module users.
> Ie. make the register of a netlink subsystem user (either direct
> netlink or via generic netlink) fail if the operations don't
> provide the SELinux handlers.
>
> Otherwise, the SELinux folks will continually be playing catchup
> writing the handlers.  That doesn't scale.

The scaling problem may be more related to SELinux trying to have
ultimate knowledge of all the subsystems classification. It breaks when
it is something that is not simple as a type (as in this case).

If SELinux should provide ways to add "filters" more dynamically at its
hooks - instead of having people go and look for that table and update
it then it would simplify things and we may be able to easily have
netlink users to register such filters at startup; infact we may be able
to hide this from the users in genetlink. 
One could argue that if SELinux is capable of adding such filters at its
hooks, then the problem could be moved to user space policy perhaps? 

cheers,
jamal

