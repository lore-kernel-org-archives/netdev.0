From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net:drivers/net: Miscellaneous conversions to
 ETH_ALEN
Date: Wed, 02 Oct 2013 20:31:50 -0700
Message-ID: <1380771110.2081.89.camel@joe-AO722>
References: <1380679480.2081.24.camel@joe-AO722>
	 <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
	 <1380696054.2081.35.camel@joe-AO722>
	 <CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>
	 <1380736969.2081.72.camel@joe-AO722>
	 <alpine.DEB.2.02.1310030034030.2162@localhost6.localdomain6>
	 <1380758954.2081.79.camel@joe-AO722> <1380760114.2081.81.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>, ath10k@lists.infradead.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0008.hostedemail.com ([216.40.44.8]:56344 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753442Ab3JCDbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 23:31:53 -0400
In-Reply-To: <1380760114.2081.81.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 17:28 -0700, Joe Perches wrote:
> On Wed, 2013-10-02 at 17:09 -0700, Joe Perches wrote:
> > This has been running a _long_ time (broken?) on
> > drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > 
> > $ spatch --version
> > spatch version 1.0.0-rc14 without Python support and with PCRE support
> 
> Nope.  Not hung/broken.  Just a _long_ time to run.
> 
> HANDLING: drivers/net/ethernet/mellanox/mlx4/en_rx.c
> HANDLING: drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> Note: processing took  2299.7s: drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> HANDLING: drivers/net/ethernet/mellanox/mlx4/port.c

Hi again Julia:

Oddly, just a few files took > 1000 seconds to run.
Most all the rest were < 10 seconds (no report).
A few were ~100 seconds.

HANDLING: drivers/net/ethernet/mellanox/mlx4/en_netdev.c
Note: processing took  2299.7s: drivers/net/ethernet/mellanox/mlx4/en_netdev.c
[]
HANDLING: drivers/net/wireless/ipw2x00/libipw_rx.c
Note: processing took  5308.0s: drivers/net/wireless/ipw2x00/libipw_rx.c
[]
HANDLING: drivers/net/wireless/hostap/hostap_80211_rx.c
Note: processing took  1336.6s: drivers/net/wireless/hostap/hostap_80211_rx.c

I don't know what causes the delays on these files.

The only output I get for net-next is:

* TODO
[[view:drivers/net/wireless/zd1201.c::face=ovl-face1::linb=331::colb=3::cole=9][ drivers/net/wireless/zd1201.c::331]]
* TODO
[[view:drivers/net/wireless/zd1201.c::face=ovl-face1::linb=332::colb=3::cole=9][ drivers/net/wireless/zd1201.c::332]]
* TODO
[[view:drivers/net/wireless/zd1201.c::face=ovl-face1::linb=332::colb=3::cole=9][ drivers/net/wireless/zd1201.c::332]]
* TODO
[[view:drivers/net/wireless/zd1201.c::face=ovl-face1::linb=332::colb=3::cole=9][ drivers/net/wireless/zd1201.c::332]]
* TODO
[[view:drivers/net/wireless/zd1201.c::face=ovl-face1::linb=333::colb=3::cole=9][ drivers/net/wireless/zd1201.c::333]]
* TODO
[[view:drivers/net/wireless/ath/ath10k/wmi.c::face=ovl-face1::linb=1761::colb=1::cole=7][ drivers/net/wireless/ath/ath10k/wmi.c::1761]]

and the zd1201 conversions would be kind of odd.

Anyway, the ath10k file is a good one to patch.  Thanks.
I'll send a patch separately.
