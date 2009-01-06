From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 06 Jan 2009 09:04:58 +0100
Message-ID: <87hc4cvp05.fsf@macbook.be.48ers.dk>
References: <20090106061414.GA3677@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:54919 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbZAFIFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 03:05:04 -0500
Received: by ewy10 with SMTP id 10so8307067ewy.13
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2009 00:05:02 -0800 (PST)
In-Reply-To: <20090106061414.GA3677@localhost> (Wu Fengguang's message of "Tue\, 6 Jan 2009 14\:14\:14 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:

 Wu> Some cheap devices ship with dangling EEPROM pins!
 Wu> They always return invalid address ff:ff:ff:ff:ff:ff.

 Wu> Inherit the auto-generated address in this case,
 Wu> so that these products can work with zero configuration.

 Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

 Wu> +	/*
 Wu> +	 * Overwrite the auto-generated address only with good ones.
 Wu> +	 */
 Wu> +	if (is_valid_ether_addr(mac))
 Wu> +		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
 Wu> +

Do we automatically get a random address in netdev nowadays without
calling random_ether_addr? I didn't know that.

Anyway, I would prefer to add a dev_warn mentioning the fact that
we're using a random address (and which one).

Other than that,

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
