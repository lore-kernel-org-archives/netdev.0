From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,0/4] hv_netvsc: Ethtool handler to change UDP hash levels
Date: Mon, 21 Aug 2017 19:22:36 -0700
Message-ID: <1503368560-14331-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The patch set adds the functions to switch UDP hash level between
L3 and L4 by ethtool command. UDP over IPv4 and v6 can be set
differently. The default hash level is L4. We currently only
allow switching TX hash level from within the guests.

The ethtool callback function is triggered by command line, and
update the per device variables of the hash level.

On Azure, fragmented UDP packets is not yet supported with L4
hashing, and may have high packet loss rate. Using L3 hashing is
recommended in this case. This ethtool option allows a user to
make this selection.

Haiyang Zhang (4):
  hv_netvsc: Clean up unused parameter from netvsc_get_hash()
  hv_netvsc: Clean up unused parameter from netvsc_get_rss_hash_opts()
  hv_netvsc: Add ethtool handler to set and get UDP hash levels
  hv_netvsc: Update netvsc Document for UDP hash level setting

 Documentation/networking/netvsc.txt |   22 ++++++++--
 drivers/net/hyperv/hyperv_net.h     |    2 +
 drivers/net/hyperv/netvsc_drv.c     |   77 +++++++++++++++++++++++++++++++----
 3 files changed, 88 insertions(+), 13 deletions(-)
