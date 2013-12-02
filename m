From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: [GIT PULL] xhci: Regression fix for 3.13.
Date: Mon, 2 Dec 2013 12:49:08 -0800
Message-ID: <cover.1386017042.git.sarah.a.sharp@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Mark Lord <mlord@pobox.com>, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40948 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754185Ab3LBUtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Dec 2013 15:49:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit c24cb6c8b501ebdf1aacec7960110a9741a45ced:

  Merge tag 'fixes-for-v3.13-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/balbi/usb into usb-linus (2013-11-27 09:49:03 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/sarah/xhci.git tags/for-usb-linus-2013-12-02

for you to fetch changes up to 35773dac5f862cb1c82ea151eba3e2f6de51ec3e:

  usb: xhci: Link TRB must not occur within a USB payload burst (2013-12-02 11:57:10 -0800)

----------------------------------------------------------------
xhci: Regression fix for 3.13.

Hi Greg,

Here's one bug fix for 3.13.

usb-net added support for bulk scatter-gather in 3.12, and it triggered a
bug in the xHCI driver.  This bug causes xHCI hosts to send an unexpected
short transfer, which will cause the USB ethernet device to stop sending
packets.

The patch is marked for the 3.12 stable kernel.  It's a long standing bug,
but the usb-net drivers are the first to trigger it.  The only other
driver that does bulk scatter-gather (usb-storage) will not trigger this
bug.

I'm not sure what the effect of the no-op TRBs will be on various xHCI
host controllers, so I would only like to be conservative and only queue
it for 3.13 and 3.12 stable.

Please queue this for 3.13.

Sarah Sharp

----------------------------------------------------------------
David Laight (1):
      usb: xhci: Link TRB must not occur within a USB payload burst

 drivers/usb/host/xhci-ring.c |   54 ++++++++++++++++++++++++++++++++++++++++-
 include/linux/usb.h          |    2 +
 2 files changed, 54 insertions(+), 2 deletions(-)
