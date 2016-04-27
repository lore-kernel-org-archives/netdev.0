From: Petko Manolov <petkan@mip-labs.com>
Subject: [PATCH v3 0/2] pegasus: correct buffer & packet sizes
Date: Wed, 27 Apr 2016 14:24:48 +0300
Message-ID: <1461756290-27421-1-git-send-email-petkan@mip-labs.com>
Cc: davem@davemloft.net, a1291762@gmail.com, johannes@sipsolutions.net,
	Petko Manolov <petkan@mip-labs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:42492 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751630AbcD0LY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 07:24:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noticed by Lincoln Ramsay <a1291762@gmail.com> some old (usb 1.1) Pegasus
based devices may actually return more bytes than the specified in the datasheet
amount.  That would not be a problem if the allocated space for the SKB was
equal to the parameter passed to usb_fill_bulk_urb().  Some poor bugger (i
really hope it was not me, but 'git blame' is useless in this case, so anyway)
decided to add '+ 8' to the buffer length parameter.  Sometimes the usb transfer
overflows and corrupts the socket structure, leading to kernel panic.

The above doesn't seem to happen for newer (Pegasus2 based) devices which did
help this bug to hide for so long.

The new default is to not include the CRC at the end of each received package.  
So far CRC has been ignored which makes no sense to do it in a first place.

The patch is against v4.6-rc5 and was tested on ADM8515 device by transferring
multiple gigabytes of data over a couple of days without any complaints from the
kernel.  Please apply it to whatever net tree you deem fit.

Changes since v1:

 - split the patch in two parts;
 - corrected the subject lines;

Changes since v2:

 - do not append CRC by default (based on a discussion with Johannes Berg);

Petko Manolov (2):
  pegasus: fixes URB buffer allocation size;
  pegasus: fixes reported packet length

 drivers/net/usb/pegasus.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
2.8.0.rc3
