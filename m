From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/9] net: dsa: mv88e6xxx: restore VLANTable map
 control
Date: Fri, 26 Feb 2016 22:04:19 +0100
Message-ID: <20160226210419.GA1560@lunn.ch>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1456510568-13679-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <56D0B964.4090002@elecsyscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
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
To: Kevin Smith <kevin.smith@elecsyscorp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56D0B964.4090002@elecsyscorp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 26, 2016 at 08:45:28PM +0000, Kevin Smith wrote:
> Hi Vivien,
> 
> On 02/26/2016 12:16 PM, Vivien Didelot wrote:
> > +	/* allow CPU port or DSA link(s) to send frames to every port */
> > +	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
> > +		output_ports = mask;
> > +	} else {

> Is this always correct?  Are there situations where a CPU or neighboring 
> switch should not be allowed to access another port? (e.g. Figure 6 or 7 
> in the 88E6352 functional specification).

What do these figures show?

The CPU port needs to be able to send to each external port. The whole
DSA concept is that Linux has a netdev per external port, and can send
frames using the netdev out a specific port. Such frames have a DSA
header indicating which port they are destined to.  When you have a
multi chip setup, the frame needs to traverse DSA ports.

      Andrew
