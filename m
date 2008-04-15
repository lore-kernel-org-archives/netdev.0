From: Mandeep Singh Baines <msb@google.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Tue, 15 Apr 2008 10:39:31 -0700
Message-ID: <20080415173931.GA1000@google.com>
References: <48007CA0.6030002@garzik.org> <20080414180338.GA18335@google.com> <20080415.003153.30044057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, joe@perches.com,
	nil@google.com, thockin@google.com, matthew@wil.cx
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:8284 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbYDORkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 13:40:04 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m3FHdq09005763
	for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 18:39:53 +0100
Received: from nf-out-0910.google.com (nfdb21.prod.google.com [10.48.129.21])
	by zps38.corp.google.com with ESMTP id m3FHdJ8I022539
	for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 10:39:51 -0700
Received: by nf-out-0910.google.com with SMTP id b21so608886nfd.1
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 10:39:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080415.003153.30044057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller (davem@davemloft.net) wrote:
> From: Mandeep Singh Baines <msb@google.com>
> Date: Mon, 14 Apr 2008 11:03:38 -0700
> 
> > Currently, it is not possible to read/write to an eeprom larger than
> > 128k in size because the buffer used for temporarily storing the
> > eeprom contents is allocated using kmalloc. kmalloc can only allocate
> > a maximum of 128k depending on architecture.
> > 
> > Modified ethtool_get/set_eeprom to only allocate a page of memory and
> > then copy the eeprom a page at a time.
> > 
> > Updated original patch as per suggestions from Joe Perches.
> > 
> > Signed-off-by: Mandeep Singh Baines <msb@google.com>
> 
> This looks fine on the surface.
> 
> But I wonder what we can do if we have some EEPROM implementation
> that can only write the whole time at once, and thus will fail
> if you try to do it in pieces?  Do we have such a case?
> 

I suspect such a case does not exist but can't say for certain. Currently,
the only user-space application I'm aware of which makes use of the set_eeprom
ioctl interface is ethtool. It currently only supports single byte writes.
Hence, any device which supports set_eeprom will likely also support
single byte writing.

To test my changes, I had to modify the ethtool application to support writing
an arbitrary number of bytes to eeprom. This makes it possible to update an
eeprom from a binary file. To do so, I use ethtool as follows:

# ethtool -E eth1 < eeprom.bin

I plan on sending my ethtool changes to the maintainers once this patch
is accepted.

> If so this new code could cause regressions.

An alternative would be to vmalloc the entire size to avoid the potential
regression.
