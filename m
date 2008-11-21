From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Thu, 20 Nov 2008 21:20:45 -0800
Message-ID: <20081120212045.27879d22@extreme>
References: <20080915165101.M68109@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Ethan <ethanhsiao@jmicron.com>, akeemting <akeem@jmicron.com>
To: cooldavid@cooldavid.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52930 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbYKUFUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 00:20:48 -0500
In-Reply-To: <20080915165101.M68109@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Going through this driver for net_device_ops makes me wonder
why some other things wer not caught during the review process.

1. Obfuscation by macro which looks like some "vendor support older kernels"
   stuff.  See the wrapping of NAPI and NET_STAT

2. 5 tasklets for thing that could be done by NAPI and one tasklet

3. 4 atomic variables for things that should be already covered by locks

4. 3 locks, seems like more than needed.

5. PCI setup of max read request size should be done via pci_set_readrq
   not by direct manipulation of PCI registers.

6. Not using pci dma allocation which is more standard convention

7. NAPI weight is very large 256 (vs normal 64)


