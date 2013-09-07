From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: Restore a call to config_init
Date: Sat, 07 Sep 2013 07:43:33 -0700
Message-ID: <1378565013.26319.3.camel@edumazet-glaptop>
References: <1378461302.15758.2.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20130906.144733.708978789363351557.davem@davemloft.net>
	 <1378507183.31445.53.camel@edumazet-glaptop>
	 <CAM8tLiNj-s0RKUeKePDURK7W7HZF=8Zz7D073qcqCLmy75CevQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, davej@redhat.com
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:49344 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab3IGOnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 10:43:35 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so4381385pbc.17
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 07:43:34 -0700 (PDT)
In-Reply-To: <CAM8tLiNj-s0RKUeKePDURK7W7HZF=8Zz7D073qcqCLmy75CevQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-07 at 13:35 +0300, Dmitry Kravkov wrote:
> On Sat, Sep 7, 2013 at 1:39 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Oh well, latest net tree broke bnx2x again.
> >
> > No idea why.
> >
> > [   61.203313] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   74.021238] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   76.109176] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   78.198178] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   80.286960] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   93.031584] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   95.069939] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   97.133493] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [   99.195912] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [  112.026026] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [  114.087991] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [  116.148976] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> > [  118.237310] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> 
> Unable to reproduce ,,,
> Which HW you have - i will try to get similar...
> Thanks
> --


To have a working NIC, I had to revert 

937e5c3 bnx2x: Restore a call to config_init
9b0be65 bnx2x: fix broken compilation with CONFIG_BNX2X_SRIOV is not set
c0a77ec bnx2x: Add missing braces in bnx2x:bnx2x_link_initialize
60cad4e bnx2x: VF RSS support - VF side
b9871bc bnx2x: VF RSS support - PF side

# lspci -s 03:00.0
03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57712 10 Gigabit Ethernet (rev 01)

$ grep BNX2X .config
# CONFIG_SCSI_BNX2X_FCOE is not set
CONFIG_BNX2X=m
