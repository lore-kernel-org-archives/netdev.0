From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: [PATCH 4.1] [media] media/vivid-osd: fix info leak in ioctl
Date: Tue, 26 Jan 2016 08:44:54 +0900
Message-ID: <56A6B376.4010507@jp.fujitsu.com>
References: <1453718538-21691-1-git-send-email-machida.yuki@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org,
	=?UTF-8?Q?Salva_Peir=c3=b3?= <speirofr@gmail.com>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:36012 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395AbcAYXo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:44:59 -0500
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id B3281AC0255
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2016 08:44:54 +0900 (JST)
In-Reply-To: <1453718538-21691-1-git-send-email-machida.yuki@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has sent to the wrong Mainling List.
sorry.

On 2016=E5=B9=B401=E6=9C=8825=E6=97=A5 19:42, Yuki Machida wrote:
> commit eda98796aff0d9bf41094b06811f5def3b4c333c upstream.
>
> The vivid_fb_ioctl() code fails to initialize the 16 _reserved bytes =
of
> struct fb_vblank after the ->hcount member. Add an explicit
> memset(0) before filling the structure to avoid the info leak.
>
> This fixes CVE-2015-7884.
>
> Signed-off-by: Salva Peir=C3=B3 <speirofr@gmail.com>
> Signed-off-by: Hans Verkuil <hans.verkuil@cisco.com>
> Signed-off-by: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
> Signed-off-by: Yuki Machida <machida.yuki@jp.fujitsu.com>
> ---
>   drivers/media/platform/vivid/vivid-osd.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/media/platform/vivid/vivid-osd.c b/drivers/media=
/platform/vivid/vivid-osd.c
> index 084d346..e15eef6 100644
> --- a/drivers/media/platform/vivid/vivid-osd.c
> +++ b/drivers/media/platform/vivid/vivid-osd.c
> @@ -85,6 +85,7 @@ static int vivid_fb_ioctl(struct fb_info *info, uns=
igned cmd, unsigned long arg)
>   	case FBIOGET_VBLANK: {
>   		struct fb_vblank vblank;
>
> +		memset(&vblank, 0, sizeof(vblank));
>   		vblank.flags =3D FB_VBLANK_HAVE_COUNT | FB_VBLANK_HAVE_VCOUNT |
>   			FB_VBLANK_HAVE_VSYNC;
>   		vblank.count =3D 0;
>
