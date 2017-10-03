From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: br: Fix igmp snooping offload with
 CONFIG_BRIDGE_VLAN_FILTERING
Date: Tue, 3 Oct 2017 17:30:31 +0200
Message-ID: <20171003153031.GP17713@lunn.ch>
References: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
 <37af5488-a064-37dc-b1ce-373119ae7b05@lab.ntt.co.jp>
 <20171003121636.GB13548@lunn.ch>
 <ad0d7686-298b-02c7-d8f8-b9363f4630f3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        David Miller <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:37359 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752374AbdJCPai (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 11:30:38 -0400
Content-Disposition: inline
In-Reply-To: <ad0d7686-298b-02c7-d8f8-b9363f4630f3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The vlan will be effective only when vlan_filtering is enabled.
> When vlan_filtering is disabled, vlan information is still kept in the
> bridge and gets effective later when vlan_filtering becomes enable.

O.K, so things are starting to get clearer.

So when vlan filtering is disabled, the hardware should just ignore
the requests to add the vlan to the hardware?

When vlan_filtering is enabled, are all the vlans in the software
bridge again offloaded? Or do we need to remember all the vlans which
we ignored while vlan filtering was disabled? The average switch has
nowhere to store these disabled vlans. It can only store active vlans.

      Andrew
