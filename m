From: Alexander Aring <alex.aring@gmail.com>
Subject: dhcp nfsroot booting failure on bb white
Date: Wed, 12 Aug 2015 10:36:53 +0200
Message-ID: <20150812083629.GA778@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mugunthanvnm@ti.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36417 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933557AbbHLIhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:37:06 -0400
Received: by wicja10 with SMTP id ja10so104113522wic.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 01:37:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

my beaglebone (white edition) fails to boot via dhcp and nfsroot. The
last messages which I see are:

...
[    2.970593] Sending DHCP requests .
[    5.996876] cpsw 4a100000.ethernet eth0: Link is Up - 100Mbps/Full -
flow control off


then it stucks forever. I reverted the recently cpsw patches:

32a7432c0fb8b0117961bdc7ab256667d039de16 ("drivers: net: cpsw: add
separate napi for tx")

d354eb85d61803e07831b68d1985cd9cfe2f8b59 ("drivers: net: cpsw:
dual_emac: simplify napi usage")

870915feabdc3af5f0ebb72d1fcf96bff01837b0 ("drivers: net: cpsw: remove
disable_irq/enable_irq as irq can be masked from cpsw itself")


I did a test after each revert, I finally figured out that after reverting
the last patch:

870915feabdc3af5f0ebb72d1fcf96bff01837b0 ("drivers: net: cpsw: remove
disable_irq/enable_irq as irq can be masked from cpsw itself")

it worked again to boot via dhcp nfsroot.


My bootparameters are:

commandline: console=ttyO0,115200n8 console=ttyO0,115200n8 ip=dhcp
root=/dev/nfs nfsroot=$IP:$NFS_EXPORT,v3,tcp

- Alex
