From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: bcm_sf2: Configure IMP port
 TC2QOS mapping
Date: Sat, 2 Sep 2017 19:47:53 +0200
Message-ID: <20170902174753.GA8981@lunn.ch>
References: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
 <1504310354-42773-5-git-send-email-f.fainelli@gmail.com>
 <20170902163057.GB5463@lunn.ch>
 <e0d92f15-342d-2b5b-2f7d-aedba328116f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54548 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752708AbdIBRr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 2 Sep 2017 13:47:58 -0400
Content-Disposition: inline
In-Reply-To: <e0d92f15-342d-2b5b-2f7d-aedba328116f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 02, 2017 at 09:32:08AM -0700, Florian Fainelli wrote:
> 
> 
> On 09/02/2017 09:30 AM, Andrew Lunn wrote:
> >> @@ -129,6 +130,14 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
> >>  	reg |= MII_DUMB_FWDG_EN;
> >>  	core_writel(priv, reg, CORE_SWITCH_CTRL);
> >>  
> >> +	/* Configure Traffic Class to QoS mapping, allow each priority to map
> >> +	 * to a different queue number
> >> +	 */
> >> +	reg = core_readl(priv, CORE_PORT_TC2_QOS_MAP_PORT(port));
> >> +	for (i = 0; i < 8; i++)
> >> +		reg |= i << (PRT_TO_QID_SHIFT * i);
> > 
> > Hi Florian
> > 
> > Rather than 8, would ds->num_tx_queues be more descriptive?
> 
> I actually have a patch on top of this which defines a constant for the
> number of queues instead of open coding 8 here. Thanks!

Hi Florian

It sounds like it should be part of 3/4?

   Andrew
