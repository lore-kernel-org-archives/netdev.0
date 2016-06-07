From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v5] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 7 Jun 2016 20:04:50 +0200
Message-ID: <20160607180450.GM29844@pali>
References: <1465313627-13479-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang@realtek.com, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>,
	anthony.wong@canonical.com, Greg KH <gregkh@linuxfoundation.org>
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465313627-13479-1-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi! Another problem which I found now:

On Tuesday 07 June 2016 10:33:47 Mario Limonciello wrote:
> +	ret =3D hex2bin(buf, obj->string.pointer + 9, 6);
> +	if (!(ret =3D=3D 0 && is_valid_ether_addr(buf))) {
> +		netif_warn(tp, probe, tp->netdev,
> +			   "Invalid MAC when reading pass-thru MAC addr: "
> +			   "%pM\n",
> +			   buf);
> +		goto amacout;
> +	}

In case when hex2bin returns zero, but is_valid_ether_addr returns
false, this function returns also zero. And thats wrong, because error
occur.

--=20
Pali Roh=C3=A1r
pali.rohar@gmail.com
