From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Tue, 16 May 2017 14:47:59 +0200
Message-ID: <20170516124759.GB27959@lunn.ch>
References: <58F9FD64.80506@aoifes.com>
 <20170425082741.59428876@xeon-e3>
 <5901DE9F.1070005@aoifes.com>
 <20170427130450.GL17172@lunn.ch>
 <59032D8B.1010801@aoifes.com>
 <20170428122259.GH13231@lunn.ch>
 <59105EA3.9030203@aoifes.com>
 <20170508123852.GI27709@lunn.ch>
 <591AD990.901@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Rafa Corvillo <rafael.corvillo@aoifes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60320 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751449AbdEPMsB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 08:48:01 -0400
Content-Disposition: inline
In-Reply-To: <591AD990.901@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Adding 8 bytes (sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN + 8
> (EDSA_HLEN)) does not fix the error, because the interface keep
> having a maximum length of 1518 bytes (sky2->netdev->mtu + ETH_HLEN
> + VLAN_HLEN).

Did you check the value being written to here:

        /*
         * The receiver hangs if it receives frames larger than the
         * packet buffer. As a workaround, truncate oversize frames, but
         * the register is limited to 9 bits, so if you do frames > 2052
         * you better get the MTU right!
         */
        thresh = sky2_get_rx_threshold(sky2);
        if (thresh > 0x1ff)
                sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_OFF);
        else {
                sky2_write16(hw, SK_REG(sky2->port, RX_GMF_TR_THR), thresh);
                sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_ON);
        }


What is thresh?

     Andrew
