From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] net:Add sysctl_max_skb_frags
Date: Wed, 3 Feb 2016 19:25:50 +0800
Message-ID: <20160203112550.GB28003@gondor.apana.org.au>
References: <568F87AC.60405@oracle.com>
 <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <tom@herbertland.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>, Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Kodanev <alexey.kodanev@oracle.com>,
	=?iso-8859-1?Q?H=E5kon?= Bugge <haakon.bugge@oracle.com>,
	open list <linux-kernel@vger.kernel.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454488017-8822-1-git-send-email-hans.westgaard.ry@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 03, 2016 at 09:26:57AM +0100, Hans Westgaard Ry wrote:
> Devices may have limits on the number of fragments in an skb they sup=
port.
> Current codebase uses a constant as maximum for number of fragments o=
ne
> skb can hold and use.
> When enabling scatter/gather and running traffic with many small mess=
ages
> the codebase uses the maximum number of fragments and may thereby vio=
late
> the max for certain devices.
> The patch introduces a global variable as max number of fragments.
>=20
> Signed-off-by: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
> Reviewed-by: H=E5kon Bugge <haakon.bugge@oracle.com>

I have to say this seems rather dirty.  I mean if taken to the
extreme wouldn't this mean that we should disable frags altogether
if some NIC can't handle them at all?

Someone suggested earlier to partially linearise the skb, why
couldn't we do that? IOW let's handle this craziness in the crazy
drivers and not in the general stack.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
