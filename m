From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/9 RESENT] staging: r8188eu: Set device type to wlan
Date: Fri, 18 Oct 2013 16:32:52 -0500
Message-ID: <5261A904.9030908@lwfinger.net>
References: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev <netdev@vger.kernel.org>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1382129563-8496-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

The latest version of NetworkManager does not recognize the device as wireless
without this change.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
  drivers/staging/rtl8188eu/os_dep/os_intfs.c | 5 +++++
  1 file changed, 5 insertions(+)

diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c 
b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index da9f0d5..17659bb 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -707,6 +707,10 @@ int rtw_init_netdev_name(struct net_device *pnetdev, const 
char *ifname)
  	return 0;
  }
  +static const struct device_type wlan_type = {
+	.name = "wlan",
+};
+
  struct net_device *rtw_init_netdev(struct adapter *old_padapter)
  {
  	struct adapter *padapter;
@@ -722,6 +726,7 @@ struct net_device *rtw_init_netdev(struct adapter *old_padapter)
  	if (!pnetdev)
  		return NULL;
  +	pnetdev->dev.type = &wlan_type;
  	padapter = rtw_netdev_priv(pnetdev);
  	padapter->pnetdev = pnetdev;
  	DBG_88E("register rtw_netdev_ops to netdev_ops\n");
-- 
1.8.4
