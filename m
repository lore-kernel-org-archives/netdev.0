From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net] net: br: Fix igmp snooping offload with
 CONFIG_BRIDGE_VLAN_FILTERING
Date: Tue, 3 Oct 2017 19:42:11 +0300
Message-ID: <20171003164211.GA5177@shredder.mtl.com>
References: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
 <37af5488-a064-37dc-b1ce-373119ae7b05@lab.ntt.co.jp>
 <20171003121636.GB13548@lunn.ch>
 <ad0d7686-298b-02c7-d8f8-b9363f4630f3@gmail.com>
 <20171003153031.GP17713@lunn.ch>
 <87infwtd0b.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Toshiaki Makita <toshiaki.makita1@gmail.com>,
        Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38415 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751226AbdJCQmP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 12:42:15 -0400
Content-Disposition: inline
In-Reply-To: <87infwtd0b.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 03, 2017 at 12:25:08PM -0400, Vivien Didelot wrote:
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> The vlan will be effective only when vlan_filtering is enabled.
> >> When vlan_filtering is disabled, vlan information is still kept in the
> >> bridge and gets effective later when vlan_filtering becomes enable.
> >
> > O.K, so things are starting to get clearer.
> >
> > So when vlan filtering is disabled, the hardware should just ignore
> > the requests to add the vlan to the hardware?
> >
> > When vlan_filtering is enabled, are all the vlans in the software
> > bridge again offloaded? Or do we need to remember all the vlans which
> > we ignored while vlan filtering was disabled? The average switch has
> > nowhere to store these disabled vlans. It can only store active vlans.
> 
> When vlan_filtering is enabled on the bridge, the bridge code does
> propagates the default_pvid again if I recall correctly.
> 
> In my opinion the hardware mustn't ignore the VLAN requests, because we
> seem to agree that vlan_filtering disabled means that the target ports
> should not care yet about 802.1Q. So having some unused hardware VLAN
> entries and some ports with disabled 802.1Q mode must work together.
> 
> That being said we still have the wrong hardware FDB populated when
> CONFIG_BRIDGE_VLAN_FILTERING is enabled but not vlan_filtering...

The driver can make sure it's able to handle the configured
`vlan_filtering` state during port enslavement to the bridge and also
forbid it from being toggled once it's enslaved.
