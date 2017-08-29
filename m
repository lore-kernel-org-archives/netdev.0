From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch v1 1/2] dt-bindings: net: add binding documentation for
 mlxsw thermal control
Date: Tue, 29 Aug 2017 19:22:54 +0200
Message-ID: <20170829172254.GG8235@lunn.ch>
References: <1504032311-195988-1-git-send-email-vadimp@mellanox.com>
 <1504032311-195988-2-git-send-email-vadimp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, davem@davemloft.net, jiri@resnulli.us,
        ivecera@redhat.com, devicetree@vger.kernel.org,
        netdev@vger.kernel.org
To: Vadim Pasternak <vadimp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43639 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750822AbdH2RXC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 13:23:02 -0400
Content-Disposition: inline
In-Reply-To: <1504032311-195988-2-git-send-email-vadimp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +- compatible		: "mellanox,mlxsw_minimal"

Interesting product name. Is there a mlxsw_maximal planned?

> +- reg			: The I2C address of the device.
> +
> +Optional properties:
> +- cooling-phandle	: phandle of the cooling device, which is to be used
> +			  for the zone thermal control.
> +			  If absent, cooling device controlled internally by
> +			  the ASIC may be used.
> +
> +- trips			: the nodes to describe a point in the temperature
> +			  domain with key temperatures at which cooling is
> +			  recommended. Each node must contain the next values:
> +			  - type: the trip type. Expected values are:
> +			    0 - a trip point to enable active cooling;
> +			    1 - a trip point to enable passive cooling;
> +			    2 - a trip point to notify emergency;
> +			  - temperature: unsigned integer indicating the trip
> +			    temperature level in millicelsius;
> +			  - minimum cooling state allowed within the trip node;
> +			  - maximum cooling state allowed within the trip node;
> +
> +Example:
> +	asic_thermal: mlxsw_minimal@48 {
> +		compatible = "mlxsw_minimal";

You missed the vendor part.

> +		reg = <0x48>;
> +		status = "disabled";

An example with it disabled?

> +		cooling-phandle = <&cooling>;
> +
> +		trips {
> +			trip@0 {
> +				trip = <0 75000 0 0>;
> +			};

I don't know much about the thermal subsystem. But looking at other
example binding documents, you seem to do something different here to
other drivers. Why do you not use what seems to be the common format:

               trips {
                        cpu_alert0: cpu-alert0 {
                                temperature = <90000>; /* millicelsius */
                                hysteresis = <2000>; /* millicelsius */
                                type = "active";
                        };
                        cpu_alert1: cpu-alert1 {
                                temperature = <100000>; /* millicelsius */
                                hysteresis = <2000>; /* millicelsius */
                                type = "passive";
                        };
                        cpu_crit: cpu-crit {
                                temperature = <125000>; /* millicelsius */
                                hysteresis = <2000>; /* millicelsius */
                                type = "critical";
                        };
                };

	Andrew
