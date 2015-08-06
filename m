From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 3/7] net: dsa: add support for switchdev FDB
 objects
Date: Thu, 6 Aug 2015 10:52:25 -0400
Message-ID: <20150806145225.GB20660@ketchup.touchtunes.com>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1438839848-505-4-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150806140432.GC19896@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150806140432.GC19896@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15-08-06 16:04:32, Andrew Lunn wrote:
> Hi Vivien
> 
> Thanks for splitting up the big patch. This it is much easier to
> review now.
> 
> Is this patch git bisectable?

In terms of compilation, yes.

> Clearly after this patch, but before all the other patches are in, we
> will not be programming the hardware. The call into the driver is
> removed here, but the replacement is added later. But is the EOPNOTSUP
> enough that the system keeps working, by falling back to software?

You're right, it isn't. At this exact patch, issuing the example:

    bridge fdb add 3c:97:0e:11:30:6e dev swp2

returns "RTNETLINK answers: Operation not supported".

> The two driver APIs are very similar, the main difference being the
> MAC address. Can you do the refactoring first, and then make the API
> change. That means we can test each patch individually, and have
> proper git bisectability.

That'd be better indeed. I'll integrate the migration from
.fdb_{add,del,getnext} to .port_fdb_{add,del,getnext} in this patch,
then add the next patches improving FID and ATU management on top of it.

Thanks,
-v
