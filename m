From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/7] net: dsa: mv88e6xxx: drop revision
 probing
Date: Sat, 16 Apr 2016 01:43:17 +0200
Message-ID: <20160415234317.GB32136@lunn.ch>
References: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460762488-2633-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460762488-2633-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 07:21:23PM -0400, Vivien Didelot wrote:
> There is no point in having special case for the revision when probing a
> switch model. The code gets cluttered with unnecessary defines, and
> leads to errors when code such as mv88e6131_setup compares
> PORT_SWITCH_ID_6131_B2 to ps->id which mask the revision.
> 
> Drop every revision definitions, add a ps->rev variable for eventual
> runtime checking and lookup only the product number.

You forgot to update the commit message. ps->rev has been removed in
this version.

>  
>  	/* Look up the exact switch ID */

This comment now becomes meaningless. Please delete.

>  	for (i = 0; i < num; ++i)
> -		if (table[i].id == ret)
> +		if (table[i].id == (ret & 0xfff0))
>  			return table[i].name;

			Andrew
