From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/7] net: dsa: tagger simplification
Date: Tue, 30 May 2017 17:08:13 +0200
Message-ID: <20170530150813.GE22758@lunn.ch>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:21:24AM -0400, Vivien Didelot wrote:
> The DSA layer has a dsa_device_ops structure containing two members to
> tag and untag the proprietary switch header, called xmit and rcv.
> 
> The switch tree and slave private structures respectively hold a useless
> copy of the rcv and xmit functions. The tagging implementations use
> useless goto labels and only the rcv caller (partially) handles the SKB
> freeing. The rcv function also contains unused arguments.
> 
> This patchset removes the copy of rcv and xmit functions, the unused
> arguments of the rcv signature and the useless labels, and handles
> freeing of the SKB in the xmit caller.

Hi Vivien

Since these changes are dealing with the hot path of the network
stack, it would be good to see some performance results. In
particular, from a high performance machine, 10Gbps interfaces, where
DSA is enabled, as a distro kernel might have.

    Andrew
