From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 0/6] net: dsa: mv88e6131: HW bridging support
 for 6185
Date: Fri, 1 Apr 2016 14:45:18 +0200
Message-ID: <20160401124518.GB32554@lunn.ch>
References: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2016 at 04:53:40PM -0400, Vivien Didelot wrote:
> All packets passing through a switch of the 6185 family are currently all
> directed to the CPU port. This means that port bridging is software driven.
> 
> To enable hardware bridging for this switch family, we need to implement the
> port mapping operations, the FDB operations, and optionally the VLAN operations
> (for 802.1Q and VLAN filtering aware systems).

Hi Vivien

I ran these patches with my tests and got some interesting
results. Not sure if its a feature or a bug.

Hardware looks like

CPU<--->Switch0<--->Switch1<--->Switch2
         6352        6352        6185 

and the test sets up a bridge spanning the three switches. Packets are
sent between ports on this bridge.

I build three different kernel configurations for these tests:

1) 802.1D
2) 802.1D + 802.1Q
3) 802.1D + 802.1Q + VLAN filtering

With all three configurations, cross chip frames get forwarded and go
out the port they are supposed to. With kernel configuration 1) & 2),
frames from switch2 go via the CPU and are SW bridged back to Switch0
or Switch1.

However, with kernel configuration 3), the CPU never sees the
frames. The bridging is all happening in hardware. Why does this
kernel configuration do something different?

Thanks
	Andrew
