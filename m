From: David Liontooth <liontooth@cogweb.net>
Subject: wake on lan with skge?
Date: Fri, 29 Dec 2006 19:31:50 -0800
Message-ID: <4595DDA6.9090405@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-9.smtp.ucla.edu ([169.232.48.138]:40744 "EHLO
	smtp-9.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030268AbWL3Dur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 22:50:47 -0500
Received: from mail.ucla.edu (mail.ucla.edu [169.232.48.151])
	by smtp-9.smtp.ucla.edu (8.13.8/8.13.8) with ESMTP id kBU3VoMN017158
	for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 19:31:50 -0800
Received: from [128.97.221.35] (clitunno.sscnet.ucla.edu [128.97.221.35])
	(authenticated bits=0)
	by mail.ucla.edu (8.13.8/8.13.8) with ESMTP id kBU3VoNC028002
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 19:31:50 -0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Back in Jan 2005, Stephen Hemminger added wake-on-lan support to the
skge driver -- cf. http://lwn.net/Articles/120679/

I'm unable to make it wake up from a powered-down state -- is this
expected to work? I have it working fine on an e1000 nic,
using the wakeonlan package --

    $ wakeonlan -i 192.168.1.255 01:02:03:04:05:06

The motherboard is a Gigabyte K8NSC-939. I don't see an option to turn
it on or off in the BIOS.

The specs show a Marvell 8001 Gigabit Ethernet controller --  lspci:

02:0b.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001
Gigabit Ethernet Controller (rev 13)

The detailed specs at
http://www.marvell.com/products/pcconn/yukon/Yukon_88E8001_10_073103_final.pdf
states it supports WOL.

Dave

# modinfo skge
filename:       /lib/modules/2.6.19.1/kernel/drivers/net/skge.ko
description:    SysKonnect Gigabit Ethernet driver
author:         Stephen Hemminger <shemminger osdl.org>
license:        GPL
version:        1.9
vermagic:       2.6.19.1 SMP mod_unload
depends:
alias:          pci:v000010B7d00001700sv*sd*bc*sc*i*
alias:          pci:v000010B7d000080EBsv*sd*bc*sc*i*
alias:          pci:v00001148d00004300sv*sd*bc*sc*i*
alias:          pci:v00001148d00004320sv*sd*bc*sc*i*
alias:          pci:v00001186d00004C00sv*sd*bc*sc*i*
alias:          pci:v00001186d00004B01sv*sd*bc*sc*i*
alias:          pci:v000011ABd00004320sv*sd*bc*sc*i*
alias:          pci:v000011ABd00005005sv*sd*bc*sc*i*
alias:          pci:v00001371d0000434Esv*sd*bc*sc*i*
alias:          pci:v00001737d00001064sv*sd*bc*sc*i*
alias:          pci:v00001737d00001032sv*sd00000015bc*sc*i*
srcversion:     34A66981E89644C61A48CB9
parm:           debug:Debug level (0=none,...,16=all) (int)

