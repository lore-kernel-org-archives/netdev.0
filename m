From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Reverts in "net" accidentally overwrote changes in "net-next"
Date: Mon, 24 Jun 2013 14:40:53 -0400
Message-ID: <51C892B5.2020109@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:53082 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab3FXSkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 14:40:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A build warning led me to notice this revert:

 ---------------
 commit 7a1a0cbfeb31f20acc10722642198e76bbc30cb9
 Author: David S. Miller <davem@davemloft.net>
 Date:   Thu May 23 12:15:32 2013 -0700

    net: Revert unused variable changes.
    
    This reverts commits:
    
    c573972c111eb4c6b3f3250ad71e7c75cc799833
    1a5904342c7380ceddd61c0b37544d752d0b1433
    da2e2c214953f37c2a6be20226537ca5a329724c
    
    They were meant for net-next not net.
 ---------------

It appears to have been merged forward into net-next, and now
net-next has also lost the functional changes from them.

$ git checkout nn-Jun24
Switched to branch 'nn-Jun24'
$ git show c573972c111eb|patch -p1 --dry-run
patching file drivers/net/ethernet/sun/sunbmac.c
$ git show 1a5904342c738|patch -p1 --dry-run
patching file drivers/net/ethernet/korina.c
$ git show da2e2c214953f|patch -p1 --dry-run
patching file drivers/net/ethernet/apple/bmac.c

Paul.
--
