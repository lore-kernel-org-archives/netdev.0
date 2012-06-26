From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH v2 net-next 0/7] mac802154: basic wpan class-device support
Date: Tue, 26 Jun 2012 13:24:47 +0400
Message-ID: <1340702694-24706-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42562 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453Ab2FZJ3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:29:01 -0400
Received: by wgbdr13 with SMTP id dr13so5026840wgb.1
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 02:29:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

thanks for the review! I've fixed coding style issue in the patch #1.

With best regards,
Alexander

Cover letter:
=============
this patch-set binds the IEEE 802.15.4 Linux stack to the radio
transceivers. A new device-class called "wpan" is added. It represents
an interface for the radio device drivers to communicate the information
with Linux networking stack.

This is the basic support, only data-packets transmission is supported
(no MAC-layer specific commands support included here). But this set
represents a necessary minimum to implement IEEE 802.15.4 standard features
and test them on real hardware.

To test/try the wpan device-class the Atmel RF230 transceiver driver
included in this patch set. The how-to instructions are available in wiki
at the linux-wsn project site: http://code.google.com/p/linux-wsn/

Alexander Smirnov (7):
  mac802154: add wpan device-class support
  mac802154: set and get PAN id
  mac802154: short address setter
  mac802154: page and channel setter
  mac802154: mlme start request
  drivers/ieee802154: add support for the at86rf230/231 transceivers
  mac802154: add monitor listener to TX datapath

 drivers/ieee802154/Kconfig     |    6 +
 drivers/ieee802154/Makefile    |    1 +
 drivers/ieee802154/at86rf230.c |  965 ++++++++++++++++++++++++++++++++++++++++
 include/linux/nl802154.h       |   14 +-
 include/linux/spi/at86rf230.h  |   31 ++
 include/net/mac802154.h        |    8 +
 net/mac802154/Makefile         |    2 +-
 net/mac802154/ieee802154_dev.c |    4 +
 net/mac802154/mac802154.h      |    8 +
 net/mac802154/mac_cmd.c        |   29 ++
 net/mac802154/mib.c            |   92 ++++
 net/mac802154/rx.c             |    1 +
 net/mac802154/tx.c             |    2 +
 net/mac802154/wpan.c           |  559 +++++++++++++++++++++++
 14 files changed, 1709 insertions(+), 13 deletions(-)
 create mode 100644 drivers/ieee802154/at86rf230.c
 create mode 100644 include/linux/spi/at86rf230.h
 create mode 100644 net/mac802154/wpan.c

--
1.7.2.3
