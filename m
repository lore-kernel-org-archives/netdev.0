From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/8] bridge: Keep track of ports
 capable of automatic discovery.
Date: Wed, 14 May 2014 08:40:25 -0700
Message-ID: <20140514084025.1531d496@nehalam.linuxnetplumber.net>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
	<1400080168-16625-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jhs@mojatatu.com, john.r.fastabend@intel.com, shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400080168-16625-3-git-send-email-vyasevic@redhat.com>
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

On Wed, 14 May 2014 11:09:22 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> +void br_port_flags_change(struct net_bridge_port *p, unsigned long old_flags)
> +{
> +	struct net_bridge *br = p->br;
> +	unsigned long mask = old_flags ^ p->flags;
> +
> +	if (!(mask & BR_AUTO_MASK))
> +		return;
> +
> +	nbp_update_port_count(br);
> +}

Minor nit, why have negative logic here.
Instead use:
	if (mask & BR_AUTO_MASK)
		nbp_update_port_count(br);
