From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH] mv643xx_eth: Fix a possible deadlock upon ifdown
Date: Tue, 12 Mar 2013 12:36:11 +0100
Message-ID: <513F132B.4060606@ahsoftware.de>
References: <1357308422-19639-1-git-send-email-lkundrak@v3.sk> <20130104202509.GX27530@wantstofly.org> <5130E5A5.90303@ahsoftware.de> <20130312024932.GF850@wantstofly.org> <513EEF83.9070806@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lubomir Rintel <lkundrak@v3.sk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lubomir Rintel <lubo.rintel@gooddata.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <513EEF83.9070806@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 12.03.2013 10:04, schrieb Alexander Holler:

> I don't think so. Internally the driver calls mv643xx_eth_stop()
> therefore lockdep issues almost the same warning as when the interface
> is shut down (see below). And reading the code, I haven't seen how a

Btw. I consider the shutdown of the interface for just changing the MTU 
more a problem than that lockdep-warning.

E.g. I had serious problems with dhcpcd which sets the MTU to 1500 when 
an interface appears. What then happened was the following:

(1) interface comes up
(2) dhcpcd sets MTU to 1500
(3) a different MTU comes through DHCP
(4) driver shuts down if, sets MTU, turns on IF
back to (1) (endless loop)

I'm not sure if dhcpcd still does that (it's some time since I 
discovered and reported that), but I consider it a crude way to shut 
down the IF to set the MTU.

Regards,

Alexander
