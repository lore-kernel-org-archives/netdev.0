From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 3/9] net: dsa: mv88e6xxx: add support for VTU ops
Date: Tue, 2 Jun 2015 19:17:14 -0700
Message-ID: <20150603021714.GA932@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1433208470-25338-4-git-send-email-vivien.didelot@savoirfairelinux.com>
 <556D522E.90607@roeck-us.net>
 <1561034247.953427.1433295590494.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	=?iso-8859-1?Q?J=E9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39548 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbbFCCRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 22:17:20 -0400
Content-Disposition: inline
In-Reply-To: <1561034247.953427.1433295590494.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2015 at 09:39:50PM -0400, Vivien Didelot wrote:
> Guenter,
> 
> On Jun 2, 2015, at 2:50 AM, Guenter Roeck linux@roeck-us.net wrote:
> > On 06/01/2015 06:27 PM, Vivien Didelot wrote:
> >> +    /* Bringing an interface up adds it to the VLAN 0. Ignore this. */
> >> +    if (!vid)
> >> +        return 0;
> >> +
> > 
> > Me puzzled ;-). I brought this and the fid question up before.
> > No idea if my e-mail got lost or what happened.
> > 
> > Can you explain why we don't need a configuration for vlan 0 ?
> 
> Sorry for late reply. Initially, when issuing "ip link set up dev swp0",
> ndo_vlan_rx_add_vid was called to add the interface in the VLAN 0.
> 
Loading the 802.1q module has the same effect.

I think this may be on purpose; it is telling the switch to accept
packets with vid==0 (and untagged packets).

> 2 things happen here:
> 
>   * this is inconsistent with the "bridge vlan" output which doesn't seem to
>     know about a VID 0;
>   * VID 0 seems special for this switch: if an ingressing frame has VID 0, the
>     tagged port will override the VID bits with the port default VID at egress.
> 
As far as I can see, the switch treats packets with vid==0 and untaged packets
as unknown if VLAN support is enabled.

Anyway, sounds odd. Sure this isn't a configuration problem somethere ?

Thanks,
Guenter
