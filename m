From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc-phonet: Don't leak in usbpn_open
Date: Wed, 08 Aug 2012 16:05:04 -0700 (PDT)
Message-ID: <20120808.160504.2177426106219233783.davem@davemloft.net>
References: <alpine.LNX.2.00.1208072354030.3227@swampdragon.chaosbits.net>
	<201208081012.07772.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jj@chaosbits.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	gregkh@linuxfoundation.org
To: remi@remlab.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201208081012.07772.remi@remlab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Wed, 8 Aug 2012 10:12:06 +0300

> Le mercredi 8 ao=FBt 2012 00:56:26 Jesper Juhl, vous avez =E9crit :
>> We allocate memory for 'req' with usb_alloc_urb() and then test
>> 'if (!req || rx_submit(pnd, req, GFP_KERNEL | __GFP_COLD))'.
>> If we enter that branch due to '!req' then there is no problem. But =
if
>> we enter the branch due to 'req' being !=3D 0 and the 'rx_submit()' =
call
>> being false, then we'll leak the memory we allocated.
>> Deal with the leak by always calling 'usb_free_urb(req)' when enteri=
ng
>> the branch. If 'req' happens to be 0 then the call is harmless, if i=
t
>> is not 0 then we free the memory we allocated but don't need.
>>
>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
>=20
> Acked-by: R=E9mi Denis-Courmont <remi@remlab.net>

Applied.
