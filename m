From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Wed, 19 Sep 2012 16:04:38 -0700
Message-ID: <20120919160438.52ed0b1a@s6510.linuxnetplumber.net>
References: <1347894617-13614-1-git-send-email-jiri@resnulli.us>
	<20120919132248.5fced1c7@s6510.linuxnetplumber.net>
	<20120919203825.GA1460@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mlindner@marvell.com,
	linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120919203825.GA1460@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2012 22:38:25 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> You cannot call sky2_set_multicast() directly here. It is called from
> __dev_set_rx_mode(). You would have to take at lease netif_addr_lock()
> here. I think that clearer is to remember computed value....

Ugh, it would mean changing link_up to being done via workqueue.
But your code wasnt safe against changes to values from set_multicast race
either.
