From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next 1/4] net: introduce new priv_flag indicating
	iface capable of change mac when running
Date: Thu, 28 Jun 2012 23:17:34 +0100
Message-ID: <1340921854.2577.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <1340892639-1111-1-git-send-email-jpirko@redhat.com>
	<1340892639-1111-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, shimoda.hiroaki@gmail.com,
	virtualization@lists.linux-foundation.org,
	danny.kukawka@bisect.de, edumazet@google.com, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1340892639-1111-2-git-send-email-jpirko@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-28 at 16:10 +0200, Jiri Pirko wrote:
> Introduce IFF_LIFE_ADDR_CHANGE priv_flag and use it to disable
> netif_running() check in eth_mac_addr()
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  include/linux/if.h |    2 ++
>  net/ethernet/eth.c |    2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/if.h b/include/linux/if.h
> index f995c66..fd9ee7c 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -81,6 +81,8 @@
>  #define IFF_UNICAST_FLT	0x20000		/* Supports unicast filtering	*/
>  #define IFF_TEAM_PORT	0x40000		/* device used as team port */
>  #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
> +#define IFF_LIFE_ADDR_CHANGE 0x100000	/* device supports hardware address
> +					 * change when it's running */
[...]

Any device that has IFF_UNICAST_FLT can update the unicast MAC filter
while it's running; doesn't that go hand-in-hand with being able to
handle changes to the primary MAC address?  Is the new flag really
necessary at all?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
