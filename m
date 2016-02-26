From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/9] net: dsa: mv88e6xxx: restore VLANTable map
 control
Date: Fri, 26 Feb 2016 23:09:42 +0100
Message-ID: <20160226220942.GB1560@lunn.ch>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1456510568-13679-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <56D0B964.4090002@elecsyscorp.com>
 <20160226210419.GA1560@lunn.ch>
 <87d1rj6tlo.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Smith <kevin.smith@elecsyscorp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44265 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbcBZWJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 17:09:46 -0500
Content-Disposition: inline
In-Reply-To: <87d1rj6tlo.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 04:37:39PM -0500, Vivien Didelot wrote:
> Hi Kevin, Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > On Fri, Feb 26, 2016 at 08:45:28PM +0000, Kevin Smith wrote:
> >> Hi Vivien,
> >> 
> >> On 02/26/2016 12:16 PM, Vivien Didelot wrote:
> >> > +	/* allow CPU port or DSA link(s) to send frames to every port */
> >> > +	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
> >> > +		output_ports = mask;
> >> > +	} else {
> >
> >> Is this always correct?  Are there situations where a CPU or neighboring 
> >> switch should not be allowed to access another port? (e.g. Figure 6 or 7 
> >> in the 88E6352 functional specification).
> 
> Given Linux expectations (described below by Andrew) I'd say yes, this
> is always correct. But I'd be curious to know if someone has counter
> examples for this.
> 
> > What do these figures show?
> 
> The figure shows the following VLANTable config:
> 
> Port  0  1  2  3  4  5  6
>   0   -  *  *  *  -  -  *
>   1   *  -  *  *  -  -  *
>   2   *  *  -  *  -  -  *
>   3   *  *  *  -  -  -  *
>   4   -  -  -  -  -  *  -
>   5   -  -  -  -  *  -  -
>   6   *  *  *  *  -  -  -
> 
> There is two independant groups: 0, 1, 2, 3, 6 (LAN, 6 is CPU/Router),
> and 4, 5 (4 is WAN and 5 is CPU/Router):

Ah, two CPU interfaces. We don't support that yet.  I do have patches,
but i took a different approach. They just load balance, by some
definition of 'load balance' between the two CPU ports.

	   Andrew
