From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next v2 0/3] r8152: use mutex for hw settings
Date: Thu, 9 Oct 2014 18:00:23 +0800
Message-ID: <1394712342-15778-60-Taiwan-albertk@realtek.com>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-58-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

v2:
Make sure the autoresume wouldn't occur inside the mutex, otherwise
the dead lock would happen. For the purpose, adjust some code about
autosuspend/autoresume.

v1:
Use mutex to avoid that the serial hw settings would be interrupted
by other settings. Although there is no problem now, it makes the
driver more safe.

Hayes Wang (3):
  r8152: autoresume before setting feature
  r8152: adjust usb_autopm_xxx
  r8152: add mutex for hw settings

 drivers/net/usb/r8152.c | 98 +++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 83 insertions(+), 15 deletions(-)

-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
