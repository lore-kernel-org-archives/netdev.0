From: Stephen Hemminger <shemminger@osdl.org>
Subject: skge and sky2 backported driver.
Date: Mon, 31 Jul 2006 14:25:55 -0700
Message-ID: <20060731142555.31beef7e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3727 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751337AbWGaV3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 17:29:19 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a backport of the current 2.6.18 version of skge and sky2
drivers for use with older kernels.  The drivers depend on the CRC32
module.

It has been compiled and tested on RHEL (2.4) and 2.6.8
but should work on other kernels past that point. It does depend on 
ethtool_ops, if_vlan and mii support.

This version is somewhat different than the current
2.6 version:

 * no suspend/resume or wake on LAN

 * no support for reading original MAC address

 * no support for MSI on sky2

 * receive checksumming default off because earlier kernels often
   do not handle it properly with vlan's or PPP.

 * sky2 does not use NAPI because it required changes
   to netdevice.h and/or tweaking internals of netdevice
   interface to handle dual port status.

 * sky2 defaults to TSO off because until 2.6.13 there
   are issues with TCP congestion control and TSO.

 * sky2 doesn't use VLAN acceleration features
   probably doesn't make much difference.

THIS IS NOT SUPPORTED, IT IS PROVIDED AS IS.  In other words, go ahead
and mail bug reports to me <shemminger@osdl.org> but don't expect me
to be able to fix them.

http://developer.osdl.org/shemminger/releases/skge-sky2-backport.tar.bz2
