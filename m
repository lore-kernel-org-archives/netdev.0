From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: 2.6.19-rc5-mm2 -- bcm43xx busted (backing out the bcm43xx patches
	fixes it)
Date: Wed, 15 Nov 2006 20:16:37 -0600
Message-ID: <455BCA05.8000007@lwfinger.net>
References: <a44ae5cd0611141521pd342109jaae9e27aca3d2200@mail.gmail.com>
	<200611152116.30734.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
In-Reply-To: <200611152116.30734.rjw-KKrjLPT3xs0@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Wednesday, 15 November 2006 00:21, Miles Lane wrote:
>> Hello,
>>
>> The last three MM kernels have fail to give me a working bcm43xx driver.
>> The odd thing is that dmesg output seems to indicate that the driver
>> is working okay.  NetworkManager doesn't see the driver, though.
>> "iwlist scan" fails to find any access points, too.  iwconfig shows
>> "Access Point: invalid".
> 
> I can confirm the symptoms, I see them too on my test boxes.
> 
>> I tried backing out the following patches, and it fixes the problem:
>>
>> drivers/net/wireless/bcm43xx/bcm43xx.h
>> drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> drivers/net/wireless/bcm43xx/bcm43xx_power.c
>> drivers/net/wireless/bcm43xx/bcm43xx_wx.c
>>> drivers/net/wireless/bcm43xx/bcm43xx_xmit.c 

The missing patch is shown below. This patch was entitled "[PATCH] bcm43xx: Readd dropped
assignment" and submitted to wireless-2.6 by Daniel Drake on 10/17/06, but it seems to have fallen
through the cracks. It is a fix to a patch entitled "[PATCH] ieee80211: Move IV/ICV stripping into
ieee80211_rx" also submitted by Daniel Drake on 9/26/2006.

NOTE to maintainers: This problem affects BOTH wireless-2.6 and 2.6.19-rcX-mmY. At present, the
"Move IV/ICV" patch has not been incorporated into 2.6.19-rcX and it is OK.

Larry


In the patch sent by Daniel Drake under the title "[PATCH] ieee80211: Move
IV/ICV stripping into ieee80211_rx", a needed line was accidentally removed.
As my current copy of wireless-2.6.git does not contain this line, I am
(re)submitting a patch to restore that line.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -543,6 +543,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
  		break;
  	}

+	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
  	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
  	case IEEE80211_FTYPE_MGMT:
  		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
