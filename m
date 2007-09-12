From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: dscc4.c tests for "#ifndef MODULE" even though it must be modular
Date: Wed, 12 Sep 2007 09:25:04 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0709120918520.21350@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:54927 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbXILN1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:27:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  from drivers/net/wan/dscc4.c:

=====
#ifndef MODULE
static int __init dscc4_setup(char *str)
{
        int *args[] = { &debug, &quartz, NULL }, **p = args;

        while (*p && (get_option(&str, *p) == 2))
                p++;
        return 1;
}

__setup("dscc4.setup=", dscc4_setup);
#endif
=====

  but from drivers/net/wan/Kconfig:

...
config DSCC4
        tristate "Etinc PCISYNC serial board support"
        depends on HDLC && PCI && m
...

  if i read this correctly, doesn't the depends on of "&& m" mean that
that Kconfig selection can be *at most* modular, so that that
preprocessor conditional can never be satisfied?  a quick test under
"make menuconfig" seems to confirm that.

  besides, the kernel parm being defined in that call to __setup()
really violates the spirit of defining kernel parms. :-)

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
