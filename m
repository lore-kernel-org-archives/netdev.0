From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH] Bridge: Fix ipv6 mc snooping if it has no ipv6
	address.
Date: Thu, 23 Jun 2016 20:42:42 +0200
Message-ID: <20160623184242.GC5511@otheros>
References: <4375d883-a95f-d032-c678-ed2fd665c36b@dd-wrt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	Ulrich Weber <ulrich.weber@sophos.com>
To: daniel <daniel@dd-wrt.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <4375d883-a95f-d032-c678-ed2fd665c36b@dd-wrt.com>
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

Hi Daniel,

Thanks for submitting this patch here :).


On Thu, Jun 23, 2016 at 11:28:55AM +0200, daniel wrote:
> The bridge is falsly dropping ipv6 mulitcast packets
> if there is no ipv6 address assigned on the brigde and no
> external mld querier is present.

and if the bridge internal querier is enabled (usually disabled
by default in the bridge code, but enabled by default in OpenWRT
for instance).

> 
> When the bridge fails to build mld queries, because it has no
> ipv6 address, it silently returns, but keeps the local querier enabled.
> (br_multicast.c:832)

Not sure whether David or others like line numbers in commit messages, as
they can change over time.

> 
> Ipv6 multicast snooping can only work if:
>  a) an external querier is present

maybe clarify that this is an OR, not AND?


I think you can add a [PATCH net] tag, as it seems small
enough for stable kernels and fixes a potential, confusing packet
loss case.

Also maybe add a:
--
Fixes: 1d81d4c3dd88 ("bridge: check return value of ipv6_dev_get_saddr()")
--

Regards, Linus


PS: Does not seem to apply for me on either David's net branch or
Torvald's master branch.

"fatal: patch fragment without header at line 7: @@ -599,10
+612,12 @@ static inline bool"

Try using "git format-patch" and "git send-email" instead. Also
check ./scripts/get_maintainer.pl for a few more email addresses
to add.
