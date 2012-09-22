From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Sat, 22 Sep 2012 13:14:45 -0700
Message-ID: <20120922131445.611d794d@nehalam.linuxnetplumber.net>
References: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mlindner@marvell.com,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Sep 2012 17:10:17 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> +	sky2_write_rx_filter(sky2, filter);
> +	memcpy(sky2->rx_filter, filter, sizeof(sky2->rx_filter));

This isn't safe since rx_filter might be referred to from interrupt
context (ie link up PHY interrupt). Maybe using atomic64 would be
best.
