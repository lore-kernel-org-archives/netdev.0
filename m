From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 0/7] USB: don't recover device if suspend fails in system sleep
Date: Wed,  6 Mar 2013 18:25:49 +0800
Message-ID: <1362565557-15884-1-git-send-email-ming.lei@canonical.com>
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:62881 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870Ab3CFK0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 05:26:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch adds comments on interface driver suspend callback
to emphasize that the failure return value is ignored by
USB core in system sleep context, so do not try to recover
device for this case, otherwise the recovery things may confuse
resume().

Also fixes the USB serial, HID and several usbnet drivers
which may recover device in suspend failure path of system sleep.

v1:
	- fix compile failure
	- add comments about handling suspend failure in resume()

Thanks,
--
Ming Lei
