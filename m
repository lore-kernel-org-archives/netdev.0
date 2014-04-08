From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: ipv6: Should inet6_addr_del consider IFA_F_MANAGETEMPADDR?
Date: Tue, 08 Apr 2014 20:26:37 +0200
Message-ID: <53443F5D.6030509@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:62342 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757267AbaDHTEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 15:04:33 -0400
Received: from [192.168.178.101] ([84.142.80.96]) by smtp.web.de (mrweb101)
 with ESMTPSA (Nemesis) id 0MZUJt-1WHIzC2Awf-00LI7s for
 <netdev@vger.kernel.org>; Tue, 08 Apr 2014 21:04:31 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I stumbled accross the fact that inet6_addr_add as well as inet6_addr_modify
consider IFA_F_TEMPORARY whilst inet6_addr_del does not.

My understanding of IFA_F_MANAGETEMPADDR is that it allows userspace applications
to deal with temporary addresses w/o having to create / track (and possibly delete)
each and every temporary address.

This works fine when creating / modifying a global address. However when a
global address is deleted the orphaned temporary addresses remain.
Shouldn't the userspace be able to set IFA_F_MANAGETEMPADDR also for RTM_DELADDR
to signalize that the kernel should delete all related temporary addresses as well?

It would be a rather small extension to manage_tempaddrs to add a "delete" parameter
and set valid_lft=prefered_lft=0 for each temporary address if set.

Sorry if this was discussed before and I miss something.

Rgds,
Heiner
