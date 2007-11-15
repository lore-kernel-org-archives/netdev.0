From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] IPVS: Fix sysctl warnings about missing strategy
Date: Wed, 14 Nov 2007 18:10:58 -0700
Message-ID: <m1d4ucz525.fsf@ebiederm.dsl.xmission.com>
References: <200711131129.58868.borntraeger@de.ibm.com>
	<20071113.024500.155458534.davem@davemloft.net>
	<20071114021131.GB2523@verge.net.au>
	<Pine.LNX.4.58.0711150225280.3658@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	David Miller <davem@davemloft.net>, borntraeger@de.ibm.com,
	netdev@vger.kernel.org, wensong@linux-vs.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:58057 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758424AbXKOBMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 20:12:03 -0500
In-Reply-To: <Pine.LNX.4.58.0711150225280.3658@u.domain.uli> (Julian
	Anastasov's message of "Thu, 15 Nov 2007 02:38:32 +0200 (EET)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julian Anastasov <ja@ssi.bg> writes:

> 	I assume /proc/sys is still valid place, only sysctl interface
> is scheduled for removal. 

Yes. The ascii versions of the sysctls that show up in /proc/sys are
definitely still valid.

> So, as long as these entries are not
> accessible from sysctl it is safe to run without strategy handler but if
> values can be changed then we will need strategy handler to
> properly call update_defense_level() as done in proc_do_defense_mode()
> as proc_handler. There could be side effects if new mode is not applied.

Yes.  The current mode of 0644 allows them to be both read and updated
with sys_sysctl.  By removing the ctl_name entry those entries become
inaccessible from the /proc/sys interface.  Which is some easier then
writing a strategy routine.

Eric
