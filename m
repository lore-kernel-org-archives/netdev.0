From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] e1000: Dump the eeprom when a user encounters a bad
	checksum
Date: Fri, 14 Dec 2007 17:31:46 -0800
Message-ID: <1197682306.4861.72.camel@localhost>
References: <20071214233530.27189.89810.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1126 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbXLOBbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 20:31:55 -0500
In-Reply-To: <20071214233530.27189.89810.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2007-12-14 at 15:35 -0800, Auke Kok wrote: 
> +	printk(KERN_ERR "/*********************/\n");
> +	printk(KERN_ERR "Current EEPROM: 0x%04x\nCalculated    : 0x%04x\n",
> +	       csum_old, csum_new);

Multiline printks need a KERN_<level> after every newline.  Perhaps:

	printk(KERN_ERR "Current EEPROM: 0x%04x\n"
	       KERN_ERR "Calculated    : 0x%04x\n", 
	       csum_old, csum_new);

> +	printk(KERN_ERR "Offset   Values\n");
> +	printk(KERN_ERR "======   ======\n");
> +	for (i = 0; i < eeprom.len; i += 16)
> +		printk(KERN_ERR "0x%04x   "
> +		       "%02x %02x %02x %02x %02x %02x %02x %02x "
> +		       "%02x %02x %02x %02x %02x %02x %02x %02x\n",
> +		       i, data[i], data[i + 1], data[i + 2], data[i + 3],
> +		       data[i + 4], data[i + 5], data[i + 6], data[i + 7],
> +		       data[i + 8], data[i + 9], data[i + 10], data[i + 11],
> +		       data[i + 12], data[i + 13], data[i + 14], data[i + 15]);

	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1, data,
		       eeprom.len, true); 

> +	printk(KERN_ERR "Include this output when contacting your support "
> +	       "provider.\n\nThis is not a software error! Something bad "
> +	       "happened to your hardware or\nEEPROM image. Ignoring this "
> +	       "problem could result in further problems,\npossibly loss "
> +	       "of data, corruption or system hangs!\n\n");
> +	printk(KERN_ERR "The MAC Address will be reset to 00:00:00:00:00:00, "
> +	       "which is invalid\nand requires you to set the proper MAC "
> +	       "address manually before continuing\nto enable this network "
> +	       "device.\n\n");
> +	printk(KERN_ERR "Please inspect the EEPROM dump and report the issue "
> +	       "to your hardware vendor\nor Intel Customer Support: "
> +	       "linux-nics@intel.com\n");

multiline printks...

cheers,  Joe

