From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net v2] tipc: check minimum bearer MTU
Date: Thu, 1 Dec 2016 18:52:51 +0100
Message-ID: <20161201175251.GA18850@unicorn.suse.cz>
References: <20161201110205.10749A0F33@unicorn.suse.cz>
 <1480608678.16599.94.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Qian Zhang <zhangqian-c@360.cn>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480608678.16599.94.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 01, 2016 at 04:11:18PM +0000, Ben Hutchings wrote:
> On Thu, 2016-12-01 at 12:02 +0100, Michal Kubecek wrote:
> [...] 
> > +/* check if device MTU is sufficient for tipc headers */
> > +static inline bool tipc_check_mtu(struct net_device *dev, unsigned int reserve)
> > +{
> > +	if (dev->mtu >= TIPC_MIN_BEARER_MTU + reserve)
> > +		return false;
> > +	netdev_warn(dev, "MTU too low for tipc bearer\n");
> > +	return true;
> > +}
> [...]
> 
> The comment says "check if ... sufficient" but the return value
> indicates the opposite.  Could you make these consistent?

Good point. I suppose renaming the function to e.g. tipc_mtu_bad() (and
rewording the commment accordingly) would also make the code more 
readable without looking at the definition.

I'll wait for other comments and send v3 tomorrow.

> Other than that, this looks OK to me.  I haven't tested any version as
> I don't know how to use TIPC.

I checked that the patch doesn't allow enabling a bearer on top of
device with insufficient MTU and it does for sufficient (100/128), both
in eth and udp case. I also checked that lowering MTU under 100 in eth
case disables attached bearer. I didn't run any deeper test like sending
an actual traffic but the patch shouldn't affect that.

Michal Kubecek
