From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [Prism54-devel] Re: Prism54 wpa update
Date: Wed, 30 Jun 2004 08:45:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630154523.GA7294@jm.kir.nu>
References: <20040629192101.GB14482@ruslug.rutgers.edu> <20040630014930.GB7153@jm.kir.nu> <20040630151346.GE14482@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
        Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Content-Disposition: inline
In-Reply-To: <20040630151346.GE14482@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 30, 2004 at 11:13:46AM -0400, Luis R. Rodriguez wrote:
> > algorithm like WEP. IEEE 802.1X is authentication protocol which can be
> > used with IEEE 802.1X EAPOL-Key frames to distribute WEP keys _or_ with
> > WPA to generate keying material for WPA 4-Way Handshake that will
> > generate the data encryption keys.
> 
> Yes, sorry, what I was trying to distinguish was using WPA using either
> PSK or 802.1x for 4-way handshake. I did not know there were two 802.1x key
> mechanisms though, as you point out. Wherever I said just TKIP I meant over TKIP
> using a PSK. I believe the second mode of 802.1x can be used with this
> chipset, not sure of the first though (to distribute WEP keys).

I kind of though so, too, but the configuration did not match this at
all.. WPA-PSK and WPA-EAP(IEEE 802.1X/RADIUS) should use the same
settings for IEEE 802.11 auth alg and MLME auto level.

> > DOT11_AUTHENABLE should be set to DOT11_AUTH_OS for WPA modes (i.e., not
> > _SK or _BOTH like you had in some cases). DOT11_AUTH_SK can only be used
> > with static WEP configuration (i.e., not with WPA or with IEEE 802.1X
> > when using dynamic WEP key generation). DOT11_AUTH_BOTH is likewise only
> > reasonable for static WEP configuration since it includes _SK as an
> > option. 
> 
> OS stands for Open System here. Are you sure of this? I'll ask around, just to
> confirm too.

Yes, I'm sure. See IEEE 802.11 standard for details. Open System auth
alg is required for WPA. Shared keys auth alg uses WEP, so the only to
use it is to have pre-shared WEP keys. I don't remember whether FullMAC
version of PrismGT driver has a separate mode for WPA, but if not, this
oid needs to be OS. It certainly cannot be SK.

-- 
Jouni Malinen                                            PGP id EFC895FA
