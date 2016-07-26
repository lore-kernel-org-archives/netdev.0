From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] net: neigh: disallow transition to NUD_STALE if lladdr
 is unchanged in neigh_update()
Date: Tue, 26 Jul 2016 11:00:51 +0200
Message-ID: <29e635b1-a619-5abc-cbe9-836319410869@stressinduktion.org>
References: <1469513812-10330-1-git-send-email-hchunhui@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>,
	David Barroso <dbarroso@fastly.com>,
	Martin Zhang <martinbj2008@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chunhui He <hchunhui@mail.ustc.edu.cn>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469513812-10330-1-git-send-email-hchunhui@mail.ustc.edu.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26.07.2016 08:16, Chunhui He wrote:
> NUD_STALE is used when the caller(e.g. arp_process()) can't guarantee
> neighbour reachability. If the entry was NUD_VALID and lladdr is unchanged,
> the entry state should not be changed.
> 
> Currently the code puts an extra "NUD_CONNECTED" condition. So if old state
> was NUD_DELAY or NUD_PROBE (they are NUD_VALID but not NUD_CONNECTED), the
> state can be changed to NUD_STALE.
> 
> This may cause problem. Because NUD_STALE lladdr doesn't guarantee
> reachability, when we send traffic, the state will be changed to
> NUD_DELAY. In normal case, if we get no confirmation (by dst_confirm()),
> we will change the state to NUD_PROBE and send probe traffic. But now the
> state may be reset to NUD_STALE again(e.g. by broadcast ARP packets),
> so the probe traffic will not be sent. This situation may happen again and
> again, and packets will be sent to an non-reachable lladdr forever.
> 
> The fix is to remove the "NUD_CONNECTED" condition. After that the
> "NEIGH_UPDATE_F_WEAK_OVERRIDE" condition (used by IPv6) in that branch will
> be redundant, so remove it.
> 
> This change may increase probe traffic, but it's essential since NUD_STALE
> lladdr is unreliable. To ensure correctness, we prefer to resolve lladdr,
> when we can't get confirmation, even while remote packets try to set
> NUD_STALE state.
> 
> Signed-off-by: Chunhui He <hchunhui@mail.ustc.edu.cn>
> ---
> v2:
>  - change title from "net: neigh: disallow state transition DELAY->STALE in
>    neigh_update()"
>  - remove "NUD_CONNECTED" condition instead of "NUD_CONNECTED | NUD_DELAY"
>  - remove "NEIGH_UPDATE_F_WEAK_OVERRIDE" condition

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
