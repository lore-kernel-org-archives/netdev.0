From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: [PATCH] acxsm: Add _{get,set}_encodeext and improve logging in _encode
Date: Tue, 7 Feb 2006 21:04:38 +0100
Message-ID: <200602072104.39208.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

    Add _{get,set}_encodeext and improve logging in _encode
   =20
    The code in _{get,set}_encode has been reordered a bit so we have
    better logging (function entry and exit) and _{get,set}_encodeext have
    been implemented as a wrapper for the ieee80211 stack functions.

diff --git a/ioctl.c b/ioctl.c
index 041f165..1fdddd7 100644
=2D-- a/ioctl.c
+++ b/ioctl.c
@@ -1007,7 +1007,9 @@ acx_ioctl_set_encode(
 	union iwreq_data *wrqu,
 	char *extra)
 {
=2D	int result =3D ieee80211_wx_set_encode(netdev_priv(ndev), info, wrqu, e=
xtra);
+	int result;
+	FN_ENTER;
+	result =3D ieee80211_wx_set_encode(netdev_priv(ndev), info, wrqu, extra);
 	FN_EXIT1(result);
 	return result;
 }
@@ -1023,12 +1025,45 @@ acx_ioctl_get_encode(
 	union iwreq_data *wrqu,
 	char *extra)
 {
=2D	int result =3D ieee80211_wx_get_encode(netdev_priv(ndev), info, wrqu, e=
xtra);
+	int result;
+	FN_ENTER;
+	result =3D ieee80211_wx_get_encode(netdev_priv(ndev), info, wrqu, extra);
 	FN_EXIT1(result);
 	return result;
 }
=20
=2D
+/***********************************************************************
+** acx_ioctl_set_encodeext
+*/
+static int
+acx_ioctl_set_encodeext(
+	struct net_device *ndev,
+	struct iw_request_info *info,
+	union iwreq_data *wrqu,
+	char *extra)
+{
+	int result;
+	FN_ENTER;
+	result =3D ieee80211_wx_set_encodeext(netdev_priv(ndev), info, wrqu, extr=
a);
+	FN_EXIT1(result);
+	return result;
+}
+/***********************************************************************
+** acx_ioctl_get_encodeext
+*/
+static int
+acx_ioctl_get_encodeext(
+	struct net_device *ndev,
+	struct iw_request_info *info,
+	union iwreq_data *wrqu,
+	char *extra)
+{
+	int result;
+	FN_ENTER;
+	result =3D ieee80211_wx_get_encodeext(netdev_priv(ndev), info, wrqu, extr=
a);
+	FN_EXIT1(result);
+	return result;
+}
 /***********************************************************************
 */
 static int
@@ -2502,6 +2537,8 @@ static const iw_handler acx_ioctl_handle
 	/* Encoding */
 	WX(SIOCSIWENCODE)	=3D acx_ioctl_set_encode,
 	WX(SIOCGIWENCODE)	=3D acx_ioctl_get_encode,
+	WX(SIOCSIWENCODEEXT)    =3D acx_ioctl_set_encodeext,
+	WX(SIOCGIWENCODEEXT)    =3D acx_ioctl_get_encodeext,
 	/* Power saving */
 	WX(SIOCSIWPOWER)	=3D acx_ioctl_set_power,
 	WX(SIOCGIWPOWER)	=3D acx_ioctl_get_power,

=2D-=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk

"Erdbeben? Sicherlich etwas, das mit Erdberen zu tun hat." -- me, paraphras=
ed


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
