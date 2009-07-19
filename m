From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [RFC][PATCH 0/2] inet6: two cases of shadowing other variables
Date: Sun, 19 Jul 2009 20:38:39 +0200
Message-ID: <1248028721-24244-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <cases_of_shadowing_other_variables>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54994 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751202AbZGSSir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 14:38:47 -0400
In-Reply-To: <cases_of_shadowing_other_variables>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two cases of shadowing variables. 

Patches are not meant to be applied immediately, especially in the first
one I am not sure if the code is ok without adding a lock.

Can the IPv6 developers please have a look through:

Patch #1: Local variable shadows function argument. After renaming,
          the question arose whether the code is correct wrt locking.

          Please take a look at this code part, no lock is taken on
	  the pmc->idev. (There is similar code in ip6_mc_del_src()).

Patch #2: Several functions shadow a global variable.
	  Can be applied directly, but better to review wrt:
	  given that ipv6_sysctl_register() calls register_pernet_subsys(),
	  does it make sense to merge the one-row table with
	  ipv6_table_template[], or are there namespace issues?

