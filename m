From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Mon, 25 Jan 2016 22:31:41 +0100
Message-ID: <20160125213141.GA27473@lunn.ch>
References: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Aaro Koskinen <aaro.koskinen@nokia.com>,
	Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42512 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932118AbcAYVbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 16:31:44 -0500
Content-Disposition: inline
In-Reply-To: <20160125154520.GI22974@ak-desktop.emea.nsn-net.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 25, 2016 at 05:45:21PM +0200, Aaro Koskinen wrote:
> Hi,
> 
> I get the below crash on OCTEON (with octeon_mgmt interface, genphy)
> always during systemd boot.
> 
> Bisected to:
> 
> commit a9049e0c513c4521dbfaa302af8ed08b3366b41f
> Author: Andrew Lunn <andrew@lunn.ch>
> Date:   Wed Jan 6 20:11:26 2016 +0100
> 
>     mdio: Add support for mdio drivers.
> 
> [  250.179887] CPU 2 Unable to handle kernel paging request at virtual address 0000000000000000, epc == ffffffff81637bac, ra == ffffffff81637b7c
> [  250.218161] Oops[#1]:
> [  250.224970] CPU: 2 PID: 850 Comm: systemd-network Not tainted 4.5.0-rc1-octeon-distro.git-test #1
> [  250.251569] task: 8000000031188000 ti: 800000002f8e8000 task.ti: 800000002f8e8000
> [  250.251586] $ 0   : 0000000000000000 ffffffff81639774 0000000000000000 ffffffffffffffff
> [  250.251595] $ 4   : 0000000000000000 0000000000000000 ffffffff81740000 0000000000000001
> [  250.251604] $ 8   : 0000000000000001 0000000000000000 ffffffff81106100 0000000100000001
> [  250.251613] $12   : 0000000000000000 ffffffff813eb81c ffffffff8150be18 0000000000000000
> [  250.251622] $16   : 8000000031290fc0 ffffffffffffffff 8000000031290fc4 8000000031188000
> [  250.251631] $20   : 0000000000000002 0000000000000001 8000000031290fc8 800000002f8eba40
> [  250.251640] $24   : 0000000000000038 ffffffff81105fb0                                  
> [  250.251649] $28   : 800000002f8e8000 800000002f8eb740 000000fff7857f88 ffffffff81637b7c
> [  250.251651] Hi    : 431bde82d7b50717
> [  250.251653] Lo    : c8de2ac3222855ea
> [  250.251668] epc   : ffffffff81637bac __mutex_lock_slowpath+0x7c/0x190
> [  250.251675] ra    : ffffffff81637b7c __mutex_lock_slowpath+0x4c/0x190
> [  250.251684] Status: 10108ce3	KX SX UX KERNEL EXL IE 
> [  250.251686] Cause : 0080000c (ExcCode 03)
> [  250.251688] BadVA : 0000000000000000
> [  250.251690] PrId  : 000d0409 (Cavium Octeon+)
> [  250.251699] Modules linked in: pata_octeon_cf libata autofs4
> [  250.251704] Process systemd-network (pid: 850, threadinfo=800000002f8e8000, task=8000000031188000, tls=000000fff75ba700)
> [  250.251782] Stack : 8000000031290fc8 0000000000000000 0000000000000001 8000000003f9bca0
> [  250.251782] 	  8000000031290c00 ffffffff81856558 8000000031290fc0 8000000031225000
> [  250.251782] 	  0000000000000001 0000000000000000 8000000031008800 ffffffff814b6284
> [  250.251782] 	  ffffffff81639774 ffffffff81175dc4 8000000031290c00 ffffffff814baf80
> [  250.251782] 	  8000000031210000 ffffffff814b64ac 800000002f8eb810 800000002f8eb810
> [  250.251782] 	  ffffffff814f7790 8000000031290c00 ffffffff814baf80 ffffffff814baf80
> [  250.251782] 	  8000000031225000 0000000000000000 800000003290ca10 ffffffff814b66a4
> [  250.251782] 	  8000000031225000 8000000031290c00 0000000000000001 ffffffff814f7b80
> [  250.251782] 	  8000000031225000 8000000031225788 8000000031225830 0000000000001002
> [  250.251782] 	  800000002f8ebb80 ffffffff814ba81c 8000000fb7105c32 ffffffff8116aab4
> [  250.251782] 	  ...
> [  250.251784] Call Trace:
> [  250.251791] [<ffffffff81637bac>] __mutex_lock_slowpath+0x7c/0x190
> [  250.251801] [<ffffffff814b6284>] phy_probe+0x6c/0x120
> [  250.251807] [<ffffffff814b64ac>] phy_attach_direct+0xdc/0x1a8
> [  250.251814] [<ffffffff814b66a4>] phy_connect_direct+0x2c/0x98
> [  250.251822] [<ffffffff814f7b80>] of_phy_connect+0x60/0xb8
> [  250.251830] [<ffffffff814ba81c>] octeon_mgmt_open+0x36c/0xad0

Hi Aaro, Olof

I've not been able to reproduce this. I've tried a Kirkwood Qnap, a
Kirkwood DIR665, an Armada XP WRT1900AC and a Freescale Vybrid. And
i've turned on mutex debugging.... Nothing, always boots to user
space, no complaints.

     Andrew
