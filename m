From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 00/10] hv_netvsc: Eliminate the additional head room
Date: Mon, 23 Nov 2015 15:28:44 -0800
Message-ID: <1448321324-21318-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In an attempt to avoid having to allocate memory on the send path, the netvsc
driver was requesting additional head room so that both rndis header and the
netvsc packet (the state that had to persist) could be placed in the skb.
Since the amount of head room requested was exceeding the default head room
as set in LL_MAX_HEADER, we were forcing a reallocation of skb.

With this patch-set, I have reduced the size of the netvsc packet to
40 bytes and with this reduction we don't need to ask for any additional
headroom. We place the rndis header in the skb head room and we place the
netvsc packet in control buffer area in the skb.

K. Y. Srinivasan (8):
  hv_netvsc: Resize some of the variables in hv_netvsc_packet
  hv_netvsc: Rearrange the hv_negtvsc_packet to be space efficient
  hv_netvsc: Eliminate the channel field in hv_netvsc_packet structure
  hv_netvsc: Eliminate rndis_msg pointer from hv_netvsc_packet
    structure
  hv_netvsc: Eliminatte the data field from struct hv_netvsc_packet
  hv_netvsc: Eliminate send_completion from struct hv_netvsc_packet
  hv_netvsc: Eliminate send_completion_ctx from struct hv_netvsc_packet
  hv_netvsc: Don't ask for additional head room in the skb

Vitaly Kuznetsov (2):
  hv_netvsc: move subchannel existence check to netvsc_select_queue()
  hv_netvsc: remove locking in netvsc_send()

 drivers/net/hyperv/hyperv_net.h   |   48 +++++++++++++++++-------------------
 drivers/net/hyperv/netvsc.c       |   42 ++++++++++++--------------------
 drivers/net/hyperv/netvsc_drv.c   |   47 +++++++++++++++--------------------
 drivers/net/hyperv/rndis_filter.c |   21 ++++++++++------
 4 files changed, 72 insertions(+), 86 deletions(-)

-- 
1.7.4.1
