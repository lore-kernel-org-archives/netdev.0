From: Sergey Matyukevich <sergey.matyukevich.os-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org>
Subject: Re: VLAN/bridge "compression" in wifi (was: Re: [PATCH 3/8] qtnfmac:
 implement AP_VLAN iftype support)
Date: Wed, 6 Sep 2017 18:45:23 +0300
Message-ID: <20170906154522.twtesbo2rxbrhekf@bars>
References: <20170620195517.18373-1-sergey.matyukevich.os@quantenna.com>
 <20170620195517.18373-4-sergey.matyukevich.os@quantenna.com>
 <1504619151.12380.16.camel@sipsolutions.net>
 <1504621233.12380.21.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Igor Mitsyanko <igor.mitsyanko.os-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org>,
        Avinash Patil <avinashp-P/7pdk10T0iB+jHODAdFcQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1504621233.12380.21.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Johannes and all,

> > In a way this feature seems mis-designed - you never have 802.1Q tags
> > over the air, but you're inserting them on RX and stripping them on
> > TX, probably in order to make bridging to ethernet easier and not
> > have to have 802.1Q acceleration on the ethernet port, or - well - in
> > order to have an ability to do this with an ethernet card that only
> > has a single CPU port.
> 
> Ok this isn't really right either - it's only for saving the 802.1Q
> acceleration on the Ethernet port, really - and saving the extra
> bridges.
> 
> To clarify, I think what you - conceptually - want is the following
> topology:
> 
>         +--- eth0.1  ---  br.1  ---  wlan0.1
>         |
> eth0 ---+--- eth0.2  ---  br.2  ---  wlan0.2
>         |
>         +--- eth0.3  ---  br.3  ---  wlan0.3
> 
> where eth0.N is just "ip link add link eth0 name eth0.N type vlan id N"
> and br.N is obviously a bridge for each, and the wlan0.N are AP_VLAN
> type interfaces that isolate the clients against each other as far as
> wifi is concerned.
> 
> Is this correct? As far as I understand, that's the baseline topology
> that you're trying to achieve, expressed in terms of Linux networking.

That's right. In fact, hostapd is able to create this kind of network
bridge infrastructure automatically when it is built
with CONFIG_FULL_DYNAMIC_VLAN option enabled.

> Now, you seem to want to compress this to
> 
>                   +---  wlan0.1
>                   |
> eth0  ---  br  ---+---  wlan0.2
>                   |
>                   +---  wlan0.3
> 
> and have the 802.1Q tag insertion/removal that's normally configured to
> happen in eth0.N already be handled in wlan0.N.
> 
> Also correct?

Exactly. And yes, the only purpose of this 'non-conventional' mode was
to have 802.1Q acceleration on the ethernet port.

> 
> 
> We clearly don't have APIs for this, and I don't think it makes sense
> in the Linux space - the bridge and wlan0.N suddenly have tagged
> traffic rather than untagged, and the VLAN tagging is completely hidden
> from the management view.
> 
> johannes
