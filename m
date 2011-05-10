From: David Decotigny <decot@google.com>
Subject: [PATCH 0/2] Minor autonegociation changes, testers welcome
Date: Mon,  9 May 2011 17:19:06 -0700
Message-ID: <1304986748-15809-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	netdev@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following 2 patches fix a few minor issues noticed by Ben and that
I tried to address here. The code compiles and "looks" good but I
don't have the required hardware to test. If you have access to the
affected NICs, I would really appreciate your help testing the
patches:
 - stmmac: ethtool -a ethX
           ethtool -A ethX [same params except:] autoneg off
 - dl2k: ethtool -s ethX speed 10 autoneg off # should work
         likewise with 100, but not with 1000 (ethtool error)

IMHO, the main differences that could be experienced relate to the
return value of ethtool, which should now report errors more
frequently than before (most were ignored).

David Decotigny (2):
  net/stmmac: don't go through ethtool to start autonegociation
  net/dl2k: Don't reconfigure link @100Mbps when disabling autoneg
    @1Gbps

 drivers/net/dl2k.c                  |   19 ++++++-------------
 drivers/net/stmmac/stmmac_ethtool.c |   13 ++-----------
 2 files changed, 8 insertions(+), 24 deletions(-)

-- 
1.7.3.1
