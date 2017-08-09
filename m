From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: [PATCH 0/4] net-next: dsa: fix flow dissection
Date: Wed,  9 Aug 2017 14:41:15 +0200
Message-ID: <20170809124119.24320-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Muciri Gatimu <muciri-lv6y7wLVQPlWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Shashidhar Lakkavalli <shashidhar.lakkavalli-lv6y7wLVQPlWk0Htik3J/w@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
 Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

RPS and probably other kernel features are currently broken on some if not
all DSA devices. The root cause of this is that skb_hash will call the
flow_dissector. At this point the skb still contains the magic switch
header and the skb->protocol field is not set up to the correct 802.3
value yet. By the time the tag specific code is called, removing the header
and properly setting the protocol an invalid hash is already set. In the
case of the mt7530 this will result in all flows always having the same
hash.

Changes since RFC:
* use a callback instead of static values
* add cover letter

John Crispin (4):
  net-next: dsa: move struct dsa_device_ops to the global header file
  net-next: dsa: add flow_dissect callback to struct dsa_device_ops
  net-next: tag_mtk: add flow_dissect callback to the ops struct
  net-next: dsa: fix flow dissection

 include/net/dsa.h         |  9 +++++++++
 net/core/flow_dissector.c | 12 ++++++++++++
 net/dsa/dsa_priv.h        |  7 -------
 net/dsa/tag_mtk.c         | 14 ++++++++++++--
 4 files changed, 33 insertions(+), 9 deletions(-)

-- 
2.11.0
