From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [cdc_ncm] kickstart
Date: Tue, 25 Nov 2014 22:29:42 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411252210380.1677@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: alexxst@gmail.com, bjorn@mork.no
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:59543 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbaKYV3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 16:29:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjorn,
Hi Alex.

So - I tried to read and understand parts of the logic implemented in the 
cdc_ncm driver.
What I understood is:
- the device and the drive exchange "obviously" lots of infos about lengths and
   so on
- lots of sanity checks all over the place

And the basic assumption that we are working inndp 16 mode.
So there is a lot of code to write - but not a lot of logic to change, right?
Or are there differences in 32 bit mode that might need attention? (behavioural 
attention, math changes or anything)

So - first of all the tx and rx fixup functions should be changed, 
reimplementing the needed code to let them work.
I was thinking to proceed this way, but I would like to have some comments 
before moving on.
Note that all these line numbers refer to the cdc_ncm.c file in the current 
kernel git tree as of today (Nov 25 at 22:27).

1 - Have a module parameter that inhibits the current forcing of 16 bit NTBs: 
and check for it more or less at line 469 of cdc_ncm.c in function 
cdc_ncm_init.
2 - Check somehow (how?) for the format we are using in .{rx,tx}_fixup 
functions, and switch to two different distinct functions:
- one to handle 16 bits
- one to handle 32 bits
3 - Disambiguate some function names if needed: for example, cdc_ncm_ndp at 
line 983 of the cdc_ncm.c file.

Please CC me and Alex, since (at least I) am not subscribed to the list. Any 
hint or help would be greatly apreciated. Sorry for the long to / cc lists: 
what's the appropriate list for these things?
Enrico
