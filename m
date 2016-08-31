From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net] bridge: re-introduce 'fix parsing of MLDv2
	reports'
Date: Wed, 31 Aug 2016 14:24:11 +0200
Message-ID: <e00ff342-d6ee-1172-7ac2-4d13929531b4@cumulusnetworks.com>
References: <00146cf9bbd373722167f61183d5d02a9d6c080e.1472644765.git.dcaratti@redhat.com>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>, netdev@vger.kernel.org
To: Davide Caratti <dcaratti@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <00146cf9bbd373722167f61183d5d02a9d6c080e.1472644765.git.dcaratti@redhat.com>
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

On 31/08/16 14:16, Davide Caratti wrote:
> commit bc8c20acaea1 ("bridge: multicast: treat igmpv3 report with
> INCLUDE and no sources as a leave") seems to have accidentally reverted
> commit 47cc84ce0c2f ("bridge: fix parsing of MLDv2 reports"). This
> commit brings back a change to br_ip6_multicast_mld2_report() where
> parsing of MLDv2 reports stops when the first group is successfully
> added to the MDB cache.
> 
> Fixes: bc8c20acaea1 ("bridge: multicast: treat igmpv3 report with INCLUDE and no sources as a leave")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> ---
>  net/bridge/br_multicast.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index a5423a1..c5fea93 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1138,7 +1138,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
>  		} else {
>  			err = br_ip6_multicast_add_group(br, port,
>  							 &grec->grec_mca, vid);
> -			if (!err)
> +			if (err)
>  				break;
>  		}
>  	}
> 

Indeed, good catch.

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
