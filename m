From: Al Viro <viro@ftp.linux.org.uk>
Subject: [RFC] potential bug in cxgb3
Date: Sun, 23 Dec 2007 20:01:04 +0000
Message-ID: <E1J6X0S-0007Sd-AW@ZenIV.linux.org.uk>
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:52238 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbXLWUBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 15:01:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


int t3_seeprom_wp(struct adapter *adapter, int enable)
{
        return t3_seeprom_write(adapter, EEPROM_STAT_ADDR, enable ? 0xc : 0);
}

looks fishy, since t3_seeprom_write() takes the last argument in little-endian,
converts to host-endian and feeds it to pci_write_config_dword().  Passing it
a host-endian instead will end up with different values seen by the card on
l-e and b-e hosts.  Shouldn't it be s/0xc/cpu_to_le32(0xc) ?

