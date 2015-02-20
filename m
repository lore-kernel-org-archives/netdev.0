From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Fri, 20 Feb 2015 04:52:37 +0100
Message-ID: <20150220035237.GH795@lunn.ch>
References: <20150219055953.GA14247@roeck-us.net>
 <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net>
 <54E676DD.9090003@gmail.com>
 <20150220000935.GA30118@roeck-us.net>
 <54E68512.6070108@cumulusnetworks.com>
 <20150220010352.GA300@roeck-us.net>
 <54E691F2.5090205@cumulusnetworks.com>
 <20150220021843.GG795@lunn.ch>
 <54E6A11A.2060703@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46404 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753196AbbBTDzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 22:55:32 -0500
Content-Disposition: inline
In-Reply-To: <54E6A11A.2060703@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> - we keep the SW bridge fdb in sync with the HW fdb, which leads to:

I don't think this is going to be easy or efficient. At least for the
88e6060 there is no interrupt when there is a change to the
database. So we are going to have to poll. And the only way to figure
out if anything has changed is to read it all out and compare against
the last read.

I suppose we only need to update the SW fdb shortly after the SW
bridge had to perform a flood because it had no entry for the
destination MAC, or after an entry sync'ed into the SW fdb reaches
timeout age.

    Andrew
