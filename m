From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 0/7] USB: don't recover device if suspend fails in system sleep
Date: Tue,  5 Mar 2013 12:01:36 +0800
Message-ID: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:38128 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933199Ab3CEECC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 23:02:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch adds comments on interface driver suspend callback
to emphasize that the failure return value is ignored by
USB core in system sleep context, so do not try to recover
device for this case, otherwise the URB traffic scheduled
in recovery of failure path may cross system sleep, and may
cause problems.

Also fixes the USB serial, HID and several usbnet drivers
which may recover device in suspend failure path of system sleep.

Thanks,
--
Ming Lei
