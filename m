From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ethtool: add dynamic flag to ETHTOOL_{GS}RXFH
 commands
Date: Thu, 04 Feb 2016 17:53:26 -0500 (EST)
Message-ID: <20160204.175326.492457129636004051.davem@davemloft.net>
References: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
	<1454455328-706-2-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lendacky@vger.kernel.org,
	Thomas.Lendacky@amd.com, yuvalmin@broadcom.com, mchan@broadcom.com,
	mcarlson@broadcom.com, sgoutham@cavium.com, hariprasad@chelsio.com,
	_govind@gmx.com, kalesh.purayil@emulex.com, andrew@lunn.ch,
	shannon.nelson@intel.com, mitch.a.williams@intel.com,
	carolyn.wyborny@intel.com, emil.s.tantilov@intel.com,
	thomas.petazzoni@free-electrons.com, amirv@mellanox.com,
	achiad@mellanox.com, bhutchings@solarflare.com,
	mirq-linux@rere.qmqm.pl, aduyck@mirantis.com
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964938AbcBDWxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 17:53:40 -0500
In-Reply-To: <1454455328-706-2-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Tue,  2 Feb 2016 15:22:06 -0800

> Ethtool supports a few operations for modifying and controlling
> a device's RSS table. Sometimes, changes in other features of the device
> may require (or desire) changes to the RSS table. Currently there is no
> method to indicate to the driver whether the current RSS table settings
> should be maintained or overridden.

Yes, there certainly is a way to indicate this.

If the user asks for the change in the number of queues, and you
cannot retain the user's requested RSS settings, then you must fail
the queue setting change.

And vice versa.

You can't say to the user "I can adhere to your requested configuration
change, but I might undo it for some unspecified reason"

That's unacceptable behavior, and that's exactly what this dynamic
flag means.

If you cannot give the user what he asks for, precisely and reliably,
you fail the operation with an error.

There is no way I am adding code which allows these "maybe" kind of
configuration operations.  Either you can or you can't, and you tell
the user when you can't by erroring out on the operation that
invalidates the requirements.
