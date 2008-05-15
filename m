From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 12/13] QLogic VNIC: Driver Kconfig and Makefile.
Date: Thu, 15 May 2008 15:31:55 -0700
Message-ID: <adafxsjdwro.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430172156.31725.94843.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:56829 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbYEOWb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 18:31:57 -0400
In-Reply-To: <20080430172156.31725.94843.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Wed, 30 Apr 2008 22:51:56 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +config INFINIBAND_QLGC_VNIC_DEBUG
 > +	bool "QLogic VNIC Verbose debugging"
 > +	depends on INFINIBAND_QLGC_VNIC
 > +	default n
 > +	---help---
 > +	  This option causes verbose debugging code to be compiled
 > +	  into the QLogic VNIC driver.  The output can be turned on via the
 > +	  vnic_debug module parameter.

If you have runtime control of this, I suggest making it default to on,
like mthca does with:

	config INFINIBAND_MTHCA_DEBUG
		bool "Verbose debugging output" if EMBEDDED
		depends on INFINIBAND_MTHCA
		default y

otherwise distros will leave the option off and it becomes a pain to
debug problems because you force users to do compiles.
