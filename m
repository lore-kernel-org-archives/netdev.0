From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 21:07:08 +0200
Message-ID: <20160913190708.GA26181@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
 <20160913012304.GC3585@lunn.ch>
 <5c028659-db7e-9a98-7ec1-1e2d19d135f9@phrozen.org>
 <20160913131408.GE15332@lunn.ch>
 <87twdjafmr.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Crispin <john@phrozen.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87twdjafmr.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Since the former alternative is prefered, we may want to remove the
> latter soon from DSA. If this phy_port_map is needed for that case, it'd
> be preferable not to add it.

O.K, so maybe we should solve it the device tree way:


       &mdio0 {
       	      	phy_port1: phy@0 {
	      		reg = <0>;
		};

       	      	phy_port2: phy@1 {
	      		reg = <1>;
		};

       	      	phy_port3: phy@2 {
	      		reg = <2>;
		};

       	      	phy_port4: phy@3 {
	      		reg = <3>;
		};

       	      	phy_port5: phy@4 {
	      		reg = <4>;
		};

		switch@0 {
                       compatible = "qca,qca8337";

                       #address-cells = <1>;
                       #size-cells = <0>;
                       reg = <30>;

                       ports {
                               port@11 {
                                       reg = <11>;
                                       label = "cpu";
                                       ethernet = <&gmac1>;
                                       phy-mode = "rgmii";
                               };

                               port@1 {
                                       reg = <1>;
                                       label = "lan1";
				       phy-handle = <&phy_port1>;
                               };

                               port@2 {
                                       reg = <2>;
                                       label = "lan2";
				       phy-handle = <&phy_port2>;
                               };

                               port@3 {
                                       reg = <3>;
                                       label = "lan3";
				       phy-handle = <&phy_port3>;
                               };

                               port@4 {
                                       reg = <4>;
                                       label = "lan4";
				       phy-handle = <&phy_port4>;
                               };
                       };
               };
       };

and remove the phy_read() and phy_write() functions.


       Andrew
