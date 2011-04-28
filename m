From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv4 2/7] ethtool: Call ethtool's get/set_settings
 callbacks with cleaned data
Date: Thu, 28 Apr 2011 13:46:39 +0100
Message-ID: <1303994799.3032.456.camel@localhost>
References: <1303965163-8198-1-git-send-email-decot@google.com>
	 <1303965163-8198-3-git-send-email-decot@google.com>
	 <20110428073417.GA2220@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Decotigny <decot@google.com>,
	"David S. Miller" <davem@davemloft.net>, mirq-linux@rere.qmqm.pl,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110428073417.GA2220@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-04-28 at 09:34 +0200, Stanislaw Gruszka wrote:
> On Wed, Apr 27, 2011 at 09:32:38PM -0700, David Decotigny wrote:
> > --- a/drivers/net/stmmac/stmmac_ethtool.c
> > +++ b/drivers/net/stmmac/stmmac_ethtool.c
> > @@ -237,13 +237,12 @@ stmmac_set_pauseparam(struct net_device *netdev,
> >  
> >  	if (phy->autoneg) {
> >  		if (netif_running(netdev)) {
> > -			struct ethtool_cmd cmd;
> > +			struct ethtool_cmd cmd = { .cmd = ETHTOOL_SSET };
> >  			/* auto-negotiation automatically restarted */
> > -			cmd.cmd = ETHTOOL_NWAY_RST;
> 
> Why did you change ETHTOOL_NWAY_RST to ETHTOOL_SSET ?

Because the function it's calling is an implementation of ETHTOOL_SSET,
not ETHTOOL_NWAY_RST.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
