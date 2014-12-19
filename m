From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: net: ucc: tbi phy detection broken by
 058112c7efc9ef43bb511c137293dddbe6e42908
Date: Thu, 18 Dec 2014 22:49:18 -0500
Message-ID: <20141219034918.GX24110@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>
To: Len Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have been trying to move an 8360 based system from a 3.0 kernel to a
3.12 (on the way to 3.14 with ipipe/xenomai) kernel and encountered an
oops in the ucc_geth driver when using RTBI mode on one of the ucc
ports.  I haven't managed to find any commits to of_mdio or ucc_geth or
fsl_pq_mdio that would appear to address this problem, so I believe it
is still present in the latest kernel, but have not confirmed that with
testing yet.

Commit 058112c7efc9ef43bb511c137293dddbe6e42908 appears to have broken
ucc support for tbi phy detection.

With the patch in place, I am unable to get the mdio bus to create phy
devices for the tbi phy in the ucc on an 8360e, and the ucc_geth driver
causes a kernel oops, while with the patch reverted, it does create them
and the driver comes up and works.

The tbi phy is needed when using a ucc in RTBI, TBI or SGMII mode.

I am not convinced that the tbi phy really behaves quite like a real phy,
which may be why get_phy_device does not work with it.  Perhaps there
is a better way to deal with the tbi phy on the ucc for this purpose.

Certainly as it is, this patch has caused a regression though, although
probably not very many systems with ucc ports actually use one of the
affected modes so the damage isn't that great.

-- 
Len Sorensen
