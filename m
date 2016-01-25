From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: [PATCH 4.1] [media] media/vivid-osd: fix info leak in ioctl
Date: Mon, 25 Jan 2016 19:42:18 +0900
Message-ID: <1453718538-21691-1-git-send-email-machida.yuki@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuki Machida <machida.yuki@jp.fujitsu.com>,
	=?UTF-8?q?Salva=20Peir=C3=B3?= <speirofr@gmail.com>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>
To: <netdev@vger.kernel.org>, <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:55032 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932306AbcAYKmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 05:42:42 -0500
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 908ABAC0246
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 19:42:35 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit eda98796aff0d9bf41094b06811f5def3b4c333c upstream.

The vivid_fb_ioctl() code fails to initialize the 16 _reserved bytes of
struct fb_vblank after the ->hcount member. Add an explicit
memset(0) before filling the structure to avoid the info leak.

This fixes CVE-2015-7884.

Signed-off-by: Salva Peir=C3=B3 <speirofr@gmail.com>
Signed-off-by: Hans Verkuil <hans.verkuil@cisco.com>
Signed-off-by: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
Signed-off-by: Yuki Machida <machida.yuki@jp.fujitsu.com>
---
 drivers/media/platform/vivid/vivid-osd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/media/platform/vivid/vivid-osd.c b/drivers/media/p=
latform/vivid/vivid-osd.c
index 084d346..e15eef6 100644
--- a/drivers/media/platform/vivid/vivid-osd.c
+++ b/drivers/media/platform/vivid/vivid-osd.c
@@ -85,6 +85,7 @@ static int vivid_fb_ioctl(struct fb_info *info, unsig=
ned cmd, unsigned long arg)
 	case FBIOGET_VBLANK: {
 		struct fb_vblank vblank;
=20
+		memset(&vblank, 0, sizeof(vblank));
 		vblank.flags =3D FB_VBLANK_HAVE_COUNT | FB_VBLANK_HAVE_VCOUNT |
 			FB_VBLANK_HAVE_VSYNC;
 		vblank.count =3D 0;
--=20
1.9.1
