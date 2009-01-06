From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 06 Jan 2009 09:42:01 +0100
Message-ID: <874p0cvnae.fsf@macbook.be.48ers.dk>
References: <20090106061414.GA3677@localhost>
	<87hc4cvp05.fsf@macbook.be.48ers.dk>
	<20090106082928.GB19690@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:58358 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbZAFImH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 03:42:07 -0500
Received: by ey-out-2122.google.com with SMTP id 22so904818eye.37
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2009 00:42:04 -0800 (PST)
In-Reply-To: <20090106082928.GB19690@localhost> (Wu Fengguang's message of "Tue\, 6 Jan 2009 16\:29\:28 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:

Hi,

 >> Do we automatically get a random address in netdev nowadays without
 >> calling random_ether_addr? I didn't know that.

 Wu> I confirmed based on both code review and tests.
 Wu> The logic goes like this in usbnet.c:

 Wu>   80 // randomly generated ethernet address
 Wu>   81 static u8       node_id [ETH_ALEN];
 Wu> ...
 Wu> 1118 int
 Wu> 1119 usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 Wu> 1120 {
 Wu> ...
 Wu> 1168         dev->net = net;
 Wu> 1169         strcpy (net->name, "usb%d");
 Wu> 1170         memcpy (net->dev_addr, node_id, sizeof node_id);
 Wu> ...

So what happens if you plug in 2 devices without an EEPROM? Do they
get the same MAC address? That seems broken.

 >> Anyway, I would prefer to add a dev_warn mentioning the fact that
 >> we're using a random address (and which one).

 Wu> I'll do that in another patch. Since I'd like to add one more similar
 Wu> warning to dm9601_set_mac_address(). That warning helped me identify
 Wu> this bug.

Ok.

-- 
Bye, Peter Korsgaard
