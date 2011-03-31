From: Domenico Andreoli <cavokz@gmail.com>
Subject: usage of netdev_boot_setup_check() in modern NIC driver
Date: Thu, 31 Mar 2011 18:41:17 +0200
Message-ID: <20110331164117.GA14852@dandreoli.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42647 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757849Ab1CaQlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 12:41:17 -0400
Received: by wwa36 with SMTP id 36so3039806wwa.1
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 09:41:16 -0700 (PDT)
Received: from cavok by jocker with local (Exim 4.75)
	(envelope-from <cavok@dandreoli.com>)
	id 1Q5Kvt-0003sc-QV
	for netdev@vger.kernel.org; Thu, 31 Mar 2011 18:41:17 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

  I'm working on the cs89x0 driver to make it a modern dual ISA/platform
driver (it is used on some non-ISA dev boards, like my QQ2440). Funny
game that could end in nothing except some new learnings for me.

It uses the netdev_boot_setup_check() function to get the configuration
from cmdline. The only other modern ISA driver (isa_(un)register_driver)
which uses it is the 3c509, which seems to invoke and immediately
overwrite part of the values just got.

Since nowdays module params can be set on the cmdline as well, may I
simply dump netdev_boot_setup_check()? It smells of legacy stuff.

In case of multiple NICs, which is the suggested way to pass the
different parameters (irq, iomem, etc) to every card?

Do you agree that such parameters have sense only on the ISA side of
the driver?

Regards,
Domenico

-----[ Domenico Andreoli, aka cavok
 --[ http://www.dandreoli.com/gpgkey.asc
   ---[ 3A0F 2F80 F79C 678A 8936  4FEE 0677 9033 A20E BC50
