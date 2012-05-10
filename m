From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/13] net: Add and use ether_addr_equal
Date: Wed, 09 May 2012 18:48:04 -0700
Message-ID: <1336614484.1905.19.camel@joe2Laptop>
References: <cover.1336538937.git.joe@perches.com>
	<20120509.212110.437114897180819434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>, Julia Lawall <julia.lawall@lip6.fr>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120509.212110.437114897180819434.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-09 at 21:21 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue,  8 May 2012 21:56:44 -0700
> 
> > Add a boolean function to test 2 ethernet addresses for equality
> > Convert compare_ether_addr uses to ether_addr_equal
> 
> This series looks great, I'll apply all of it.

coccinelle is a nifty, better sed, tool.  Thanks Julia et al.

> That case you didn't convert in mac80211 is probably the
> bug Johannes was talking about which started this whole
> discussion.

Looks like it.

Do you want a similar patch/patches for drivers/net?

If I break it out by nominal driver/maintainer,
it'll be a highish number of low density patches.

$ git grep -w compare_ether_addr drivers/net | wc -l
59
$ git grep -w -l compare_ether_addr drivers/net | wc -l
31

Maybe just a single patch?

Also the compare_ether_addr_64bits function is
still used a couple dozen times.  Maybe another
patch for those?  ether_addr_equal_64bits?
