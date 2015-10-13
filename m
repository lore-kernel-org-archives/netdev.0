From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/6] net: dsa: implement port_fdb_dump in drivers
Date: Tue, 13 Oct 2015 12:18:49 -0400
Message-ID: <20151013161848.GA5116@ketchup.mtl.sfl>
References: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Oct. Tuesday 13 (42) 11:42 AM, Vivien Didelot wrote:
> Not all switch chips provide a Get Next kind of operation to dump FDB entries.
> It is preferred to let the driver handle the dump operation the way it works
> best for the chip. Thus, drop port_fdb_getnext and implement the port_fdb_dump
> operation in DSA, which pushes the switchdev FDB dump callback down to the
> drivers. mv88e6xxx is the only driver affected and is updated accordingly.
> 
> Vivien Didelot (6):
>   net: dsa: mv88e6xxx: write VID outside of VTU Get Next code
>   net: dsa: mv88e6xxx: write MAC outside of ATU Get Next code
>   net: dsa: add port_fdb_dump function
>   net: dsa: mv88e6xxx: implement port_fdb_dump
>   net: dsa: mv88e6xxx: remove port_fdb_getnext
>   net: dsa: remove port_fdb_getnext
> 
>  drivers/net/dsa/mv88e6171.c |   2 +-
>  drivers/net/dsa/mv88e6352.c |   2 +-
>  drivers/net/dsa/mv88e6xxx.c | 140 ++++++++++++++++++++++++--------------------
>  drivers/net/dsa/mv88e6xxx.h |   5 +-
>  include/net/dsa.h           |   8 ++-
>  net/dsa/slave.c             |  26 +-------
>  6 files changed, 90 insertions(+), 93 deletions(-)

I mispaste a few "return err" instead of "goto unlock" which skips a few
mutex_unlock() in mv88e6xxx.c. I'm sending a respin right away, please
ignore this v1.

Sorry,
-v
