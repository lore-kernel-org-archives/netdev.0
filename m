From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Mon, 17 Sep 2012 09:12:14 -0700
Message-ID: <20120917091214.5cd9b0f5@nehalam.linuxnetplumber.net>
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

> In my case I have following problem. sky2_set_multicast() sets registers
> GM_MC_ADDR_H[1-4] correctly to:
> 0000 0800 0001 0410
> However, when adapter gets link and sky2_link_up() is called, the values
> are for some reason different:
> 0000 0800 0016 0410

Rather than papering over the problem, it would be better to
trace back what is setting those registers and fix that code.

> This in my case prevents iface to be able to receive packets with dst mac
> 01:80:C2:00:00:02 (LACPDU dst mac), which I set up previously by
> SIOCADDMULTI.
> 
> So remember computed rx_filter data and write it to GM_MC_ADDR_H[1-4] on
> link_up.
>

Please do some more root cause analysis. Just save/restoring the
registers is just a temporary workaround.
