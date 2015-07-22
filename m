From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: via rhine build regression for arch/sh
Date: Wed, 22 Jul 2015 09:54:25 -0400
Message-ID: <20150722135424.GG4477@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-next@vger.kernel.org>
To: Alexey Charkov <alchark@gmail.com>,
	Antonio Borneo <borneo.antonio@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The builds of arch/sh are failing in linux-next with:

drivers/net/ethernet/via/via-rhine.c:1098:2: error: implicit declaration
of function 'pci_iomap' [-Werror=implicit-function-declaration]
drivers/net/ethernet/via/via-rhine.c:1119:2: error: implicit declaration
of function 'pci_iounmap' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors
make[5]: *** [drivers/net/ethernet/via/via-rhine.o] Error 1

http://kisskb.ellerman.id.au/kisskb/buildresult/12468878/

It either is the one line change in:

commit b7d3282a245f44286b88e436b1d08c518cdf4569
Author: Antonio Borneo <borneo.antonio@gmail.com>
Date:   Wed Jun 17 19:42:31 2015 +0800

    net: via/Kconfig: replace USE_OF with OF_???
    

..or maybe it goes back to the original OF support patch:

commit 2d283862dc62daead9db0dc89cd0d0351e91f765
Author: Alexey Charkov <alchark@gmail.com>
Date:   Tue Apr 22 19:28:09 2014 +0400

    net: via-rhine: add OF bus binding


I have not bisected to check which, but it seems likely that
it is one of the above.

Paul.
