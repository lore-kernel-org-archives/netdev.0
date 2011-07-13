From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: change return values in mac_pton() function
Date: Wed, 13 Jul 2011 13:09:03 +0300
Message-ID: <CACVxJT-TXBd5S+HNfzNR2hnGUk2hMfTSQrkodUunUXOQ6+X8eg@mail.gmail.com>
References: <1310549424-5484-1-git-send-email-arend@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1310549424-5484-1-git-send-email-arend@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 13, 2011 at 12:30 PM, Arend van Spriel <arend@broadcom.com>=
 wrote:
> The original commit adding this function noted a diverge from usual
> 0=3Dsuccess/-E=3Dfail, but no motivation for it.

I thought it was obvious, but indeed wasn't explicitely
mentioned in changelog. But see inet_pton(3).

> To stay consistent this
> commit adheres to the usual approach. The callers check for result
> is changed from 'if(!mac_pton(x, y))' to 'if(mac_pton(x,y) < 0)'.

> @@ -304,20 +304,20 @@ int mac_pton(const char *s, u8 *mac)
>
> =A0 =A0 =A0 =A0/* XX:XX:XX:XX:XX:XX */
> =A0 =A0 =A0 =A0if (strlen(s) < 3 * ETH_ALEN - 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
