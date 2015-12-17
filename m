From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/1] mac80211: improve the contiguous mask checking
Date: Thu, 17 Dec 2015 16:04:28 +0100
Message-ID: <1450364668.8247.34.camel@sipsolutions.net>
References: <1450364392-76874-1-git-send-email-zhaoxiu.zeng@gmail.com>
	 (sfid-20151217_160054_877867_44DDA348)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450364392-76874-1-git-send-email-zhaoxiu.zeng@gmail.com> (sfid-20151217_160054_877867_44DDA348)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-17 at 22:59 +0800, Zeng Zhaoxiu wrote:
> If the result of adding the first set bit to the mask is power of 2,
> the mask must be contiguous. "mask & -mask" can get the first set bit
> of mask gracefully.

> -		if (__ffs64(mask) + hweight64(mask) !=3D fls64(mask))
> {
> +		inc =3D (mask & -mask);
> +		val =3D mask + inc;
> +		if ((val & (val - 1)) !=3D 0) {
> =C2=A0			/* not a contiguous mask ... not handled now! */

Hm. Ok, I can see how that would work, but it doesn't really seem like
much of an "improvement" to me? Surely I seem to need much more
thinking to understand this. There's no reason to optimise it either,
so why should we change it?

johannes
