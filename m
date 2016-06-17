From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [patch -next] tipc: potential shift wrapping
	bug in map_set()
Date: Fri, 17 Jun 2016 12:01:22 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D224A9483@eusaamb103.ericsson.se>
References: <20160617092226.GD25609@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20160617092226.GD25609@mwanda>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Acked.  This will only be relevant in clusters > 1000 nodes, which I must admit I haven't tested yet.

///jon

> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Friday, 17 June, 2016 05:22
> To: Jon Maloy
> Cc: Ying Xue; David S. Miller; netdev@vger.kernel.org; tipc-
> discussion@lists.sourceforge.net; kernel-janitors@vger.kernel.org
> Subject: [patch -next] tipc: potential shift wrapping bug in map_set()
> 
> "up_map" is a u64 type but we're not using the high 32 bits.
> 
> Fixes: 35c55c9877f8 ('tipc: add neighbor monitoring framework')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
> index 87d4efe..0d489e8 100644
> --- a/net/tipc/monitor.c
> +++ b/net/tipc/monitor.c
> @@ -122,8 +122,8 @@ static int dom_size(int peers)
> 
>  static void map_set(u64 *up_map, int i, unsigned int v)
>  {
> -	*up_map &= ~(1 << i);
> -	*up_map |= (v << i);
> +	*up_map &= ~(1ULL << i);
> +	*up_map |= ((u64)v << i);
>  }
> 
>  static int map_get(u64 up_map, int i)

------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports. http://sdm.link/zohomanageengine
