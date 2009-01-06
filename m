From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Tue, 06 Jan 2009 12:17:56 +0100
Message-ID: <87r63gu1i3.fsf@macbook.be.48ers.dk>
References: <20090106091050.GA19316@localhost>
	<87zli4u71i.fsf@macbook.be.48ers.dk>
	<20090106094757.GA19587@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:11447 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbZAFLSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 06:18:00 -0500
Received: by ey-out-2122.google.com with SMTP id 22so911424eye.37
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2009 03:17:58 -0800 (PST)
In-Reply-To: <20090106094757.GA19587@localhost> (Wu Fengguang's message of "Tue\, 6 Jan 2009 17\:47\:57 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:

Hi,

 Wu> if (is_valid_ether_addr(mac))
 Wu> memcpy(dev->net->dev_addr, mac, ETH_ALEN);
 Wu> +	else {
 Wu> +		DECLARE_MAC_BUF(mac_buf);
 Wu> +		print_mac(mac_buf, mac);
 Wu> +		devdbg(dev, "EEPROM reported mac address %s is invalid,"
 Wu> +				" use the randomly generated one.", mac_buf);
 >> 
 >> And this should be a warning.

 Wu> Then let the warning message appear repeatedly for some devices?

This is called at probe time - But yes, I think it makes sense to print
it.

We should print the random address instead of the ff's though.

 Wu> Also dev_warn() won't be able to show the device name at that time,
 Wu> like this:

Ah yes, that's presumably why I used a raw printk just above.

 Wu> [28489.062180] : EEPROM reported mac address ff:ff:ff:ff:ff:ff is
 Wu> invalid, use the randomly generated one.

I would prefer something like:

printk(KERN_WARNING "dm9601: No valid MAC address in EEPROM, using %s\n",
       print_mac(..));

Also, it seems like you're not writing the random address to the
hardware registers, so you won't be able to receive any unicast -
You'll need to add a call to dm9601_set_mac_address() or similar.

-- 
Bye, Peter Korsgaard
