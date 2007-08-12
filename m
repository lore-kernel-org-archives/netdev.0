From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: dm9000: add set_mac_address()
Date: Sun, 12 Aug 2007 19:08:52 -0400
Message-ID: <46BF9304.9080709@pobox.com>
References: <20070812192741.GB27490@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Trimarchi <trimarchi@gandalf.sssup.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36147 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933509AbXHLXIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 19:08:55 -0400
In-Reply-To: <20070812192741.GB27490@gandalf.sssup.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

set_mac_address should not write to the SROM, as Michael noted.

The proper operations are:

     probe time:
	read MAC address from SROM

     dev open (interface up):
	write dev->dev_addr[] to RX filter (or identity) registers

EEPROM update support is available separately, via an ethtool sub-ioctl.

	Jeff



