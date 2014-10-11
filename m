From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 00/12] Coverity patches for drivers/isdn
Date: Sat, 11 Oct 2014 13:46:29 +0200 (CEST)
Message-ID: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:60913 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a series of patches for the ISDN CAPI subsystem and the
Gigaset ISDN driver.
Patches 1 to 7 are specific fixes for Coverity warnings.
Patches 8 to 11 fix related problems with the handling of invalid
CAPI command codes I noticed while working on this.
Patch 12 fixes an unrelated problem I noticed during the subsequent
regression tests.
It would be great if these could still be merged.

Thanks,
Tilman

Tilman Schmidt (12):
  isdn/gigaset: missing break in do_facility_req
  isdn/gigaset: make sure controller name is null terminated
  isdn/gigaset: limit raw CAPI message dump length
  isdn/gigaset: fix NULL pointer dereference
  isdn/gigaset: fix non-heap pointer deallocation
  isdn/capi: correct capi20_manufacturer argument type mismatch
  isdn/capi: prevent index overrun from command_2_index()
  isdn/capi: refactor command/subcommand table accesses
  isdn/capi: prevent NULL pointer dereference on invalid CAPI command
  isdn/capi: handle CAPI 2.0 message parser failures
  isdn/capi: don't return NULL from capi_cmd2str()
  isdn/gigaset: fix usb_gigaset write_cmd result race

 drivers/isdn/capi/capidrv.c        |  24 +++++-
 drivers/isdn/capi/capiutil.c       |  41 ++++++++--
 drivers/isdn/capi/kcapi.c          |   4 +-
 drivers/isdn/gigaset/capi.c        | 155 +++++++++++++++++++++++++++++++------
 drivers/isdn/gigaset/ev-layer.c    | 116 +++++++++++++++++----------
 drivers/isdn/gigaset/usb-gigaset.c |   4 +-
 include/linux/kernelcapi.h         |   2 +-
 7 files changed, 265 insertions(+), 81 deletions(-)

-- 
1.9.2.459.g68773ac
