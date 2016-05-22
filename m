From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH] net/ethoc: fix null dereference on error exit path
Date: Sun, 22 May 2016 22:42:28 +0300
Message-ID: <20160522194228.GA11011@octofox.metropolis>
References: <1463944098-7061-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463944098-7061-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Colin,

On Sun, May 22, 2016 at 08:08:18PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> priv is assigned to NULL however all the error exit paths to label 'free'
> dereference priv, causing a null pointer dereference.
> 
> Examination of the code shows that all error exits via the 'free'
> label path occur before priv is assigned to netdev_priv(netdev), hence
> there is no need to call clk_disable_unprepare and so the location of
> the label should be moved to free_netdev statement to avoid this null
> dereference on priv.

This description is a bit inaccurate. Indeed all 'goto free' above the
'priv = netdev_priv(netdev);' need to skip 'if (priv->clk)' check, but
there are two more 'goto free' below that line, and they look correct
now, but after this patch they'll leave the clock enabled.

-- 
Thanks.
-- Max
