From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Mon, 30 Aug 2004 18:30:51 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040831013050.GA7360@jm.kir.nu>
References: <20040830045441.GA7415@jm.kir.nu> <1093913355.1487.10.camel@rootix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@hpl.hp.com>, netdev@oss.sgi.com,
	hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Pedro Ramalhais <ramalhais@serrado.net>
Content-Disposition: inline
In-Reply-To: <1093913355.1487.10.camel@rootix>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 01:49:47AM +0100, Pedro Ramalhais wrote:

> #define IW_AUTH_RX_UNENCRYPTED_EAPOL   8
> I think this define isn't needed because you can get the same
> information from IW_AUTH_KEY_MGMT:
> #define IW_AUTH_KEY_MGMT_802_1X        1
> #define IW_AUTH_KEY_MGMT_PSK   2
> because if IW_AUTH_KEY_MGMT_802_1X || IW_AUTH_KEY_MGMT_PSK , then you
> want to pass unencrypted EAPOL packets.

IW_AUTH_KEY_MGMT was added to support NDIS-like drivers that want to
generate WPA IE internally. Many drivers, e.g., Host AP, do not use them
at all. Consequently, I wanted to have a separate parameter for this
particular case. Drivers do not need to implement support for both
cases.

> Likewise for IW_AUTH_WPA_ENABLED which you can get from
> IW_AUTH_WPA_VERSION:
> /* IW_AUTH_WPA_VERSION values */
> #define IW_AUTH_WPA_VERSION_DISABLED    0
> #define IW_AUTH_WPA_VERSION_WPA         1
> #define IW_AUTH_WPA_VERSION_WPA2        2
> If IW_AUTH_WPA_VERSION == IW_AUTH_WPA_VERSION_DISABLED then WPA is
> disabled, else if IW_AUTH_WPA_VERSION_WPA || IW_AUTH_WPA_VERSION_WPA2
> then it's enabled.

This is not the same. IW_AUTH_WPA_ENABLED is used to configure the
driver in WPA mode before any scan requests whereas IW_AUTH_WPA_VERSION
is used only after the scan requests. Drivers are free to not implement
IW_AUTH_WPA_ENABLED handler if they are always in "WPA mode".

-- 
Jouni Malinen                                            PGP id EFC895FA
