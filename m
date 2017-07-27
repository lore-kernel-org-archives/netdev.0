From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 07/10] net: dsa: lan9303: Added basic
 offloading of unicast traffic
Date: Thu, 27 Jul 2017 15:31:13 +0200
Message-ID: <20170727133113.GB18666@lunn.ch>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-8-privat@egil-hjelmeland.no>
 <20170726172443.GR12049@lunn.ch>
 <19cbabee-a0e5-03f1-d2fa-eea3521311a8@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19cbabee-a0e5-03f1-d2fa-eea3521311a8@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >I think you are over-simplifying here. Say i have a layer 2 VPN and i
> >bridge port 1 and the VPN? The software bridge still wants to do STP
> >on port 1, in order to solve loops.
> >
> 
> Problem is that the mainline lan9303_separate_ports() does its
> work by setting port 1 & 2 in STP BLOCKING state (and port 0 in
> FORWARDING state). So my understanding is that it would break port
> separation if LAN9303_SWE_PORT_STATE is written while the driver
> is in the non-bridged state.

If the hardware cannot do it, that is a different matter. But if the
hardware can do STP states per port, you should try to make use of it
here.

> I thought the SW bridge would carry doing its STP work even if
> there is a port_stp_state_set method on a DSA port?

It will, but it means you are dropping frames in software, adding
extra load to the CPU, reducing the available bandwidth for the other
port, etc.

       Andrew
