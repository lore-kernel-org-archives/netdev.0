From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net] net: br: Fix igmp snooping offload with
 CONFIG_BRIDGE_VLAN_FILTERING
Date: Wed, 4 Oct 2017 15:31:17 +0300
Message-ID: <20171004123117.GA12602@splinter>
References: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
 <37af5488-a064-37dc-b1ce-373119ae7b05@lab.ntt.co.jp>
 <20171003121636.GB13548@lunn.ch>
 <ad0d7686-298b-02c7-d8f8-b9363f4630f3@gmail.com>
 <20171003153031.GP17713@lunn.ch>
 <87infwtd0b.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20171003164211.GA5177@shredder.mtl.com>
 <c422306b-b6e5-34aa-4428-ea5a8b5f1a02@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Toshiaki Makita <toshiaki.makita1@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45165 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751949AbdJDMbW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 08:31:22 -0400
Content-Disposition: inline
In-Reply-To: <c422306b-b6e5-34aa-4428-ea5a8b5f1a02@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 01:52:20PM +0900, Toshiaki Makita wrote:
> On 2017/10/04 1:42, Ido Schimmel wrote:
> > The driver can make sure it's able to handle the configured
> > `vlan_filtering` state during port enslavement to the bridge and also
> > forbid it from being toggled once it's enslaved.
> 
> That is a simple solution.
> One concern is backward compatibility. I wonder if we can prohibit
> toggling for some driver which currently allows it.

IMO, it's invalid to continue to allow this when we know the requested
behavior isn't honored and packets are forwarded incorrectly.
