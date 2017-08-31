From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net/ncsi: Define {add,kill}_vid callbacks for !CONFIG_NET_NCSI
Date: Wed, 30 Aug 2017 20:59:55 -0700
Message-ID: <6D0042A3-C029-4CAC-86B1-F570E541D8C0@gmail.com>
References: <20170831033846.23538-1-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Joel Stanley <joel@jms.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831033846.23538-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On August 30, 2017 8:38:46 PM PDT, Samuel Mendoza-Jonas <sam@mendozajonas=
=2Ecom> wrote:
>Patch "net/ncsi: Configure VLAN tag filter" defined two new callback
>functions in include/net/ncsi=2Eh, but neglected the !CONFIG_NET_NCSI
>case=2E This can cause a build error if these are referenced elsewhere
>without NCSI enabled, for example in ftgmac100:
>
>>>> ERROR: "ncsi_vlan_rx_kill_vid"
>[drivers/net/ethernet/faraday/ftgmac100=2Eko] undefined!
>>>> ERROR: "ncsi_vlan_rx_add_vid"
>[drivers/net/ethernet/faraday/ftgmac100=2Eko] undefined!
>
>Add definitions for !CONFIG_NET_NCSI to bring it into line with the
>rest
>of ncsi=2Eh
>
>Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas=2Ecom>
>---
> include/net/ncsi=2Eh | 8 ++++++++
> 1 file changed, 8 insertions(+)
>
>diff --git a/include/net/ncsi=2Eh b/include/net/ncsi=2Eh
>index 1f96af46df49=2E=2E2b13b6b91a4d 100644
>--- a/include/net/ncsi=2Eh
>+++ b/include/net/ncsi=2Eh
>@@ -36,6 +36,14 @@ int ncsi_start_dev(struct ncsi_dev *nd);
> void ncsi_stop_dev(struct ncsi_dev *nd);
> void ncsi_unregister_dev(struct ncsi_dev *nd);
> #else /* !CONFIG_NET_NCSI */
>+int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16
>vid)
>+{
>+	return -ENOTTY;

Returning -EOPNOTSUPP would probably be more correct here=2E

>+}
>+int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16
>vid)
>+{
>+	return -ENOTTY;

Likewise=2E

>+}
>static inline struct ncsi_dev *ncsi_register_dev(struct net_device
>*dev,
> 					void (*notifier)(struct ncsi_dev *nd))
> {


--=20
Florian
