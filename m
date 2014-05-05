From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] bridge: Add port flap detection
Date: Mon, 05 May 2014 16:48:07 +0400
Message-ID: <53678887.1070006@cogentembedded.com>
References: <1399238974-6210-1-git-send-email-jmaxwell@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, davem@davemloft.net,
	makita.toshiaki@lab.ntt.co.jp, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	pirko@redhat.com, jmaxwell@redhat.com
To: Jon Maxwell <jmaxwell37@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399238974-6210-1-git-send-email-jmaxwell@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/05/2014 01:29 AM, Jon Maxwell wrote:

> There has been a number incidents recently where customers running KVM have reported that VM hosts on different Hypervisors are unreachable. Based on pcap traces we found that the bridge was broadcasting the ARP request out onto the network. However some NICs have an inbuilt switch which on occasions were broadcasting the VMs ARP request back through the physical NIC on the Hypervisor. This resulted in the bridge flapping ports and incorrectly learning that the VMs mac address was external. As a result the ARP reply was directed back onto the external network and VM never updated it's ARP cache. This patch will detect port flapping and log a message so that this condition can be detected earlier.

    Please wrap your changelog at 80 columns or less.

> Signed-off-by: Jon Maxwell <jmaxwell@redhat.com>

    You probably want the same RedHat email in the patch autorhship record, so 
you need to insert the below line before the changelog:

From: Jon Maxwell <jmaxwell@redhat.com>

> ---
>   net/bridge/br_fdb.c | 7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9203d5a..c08607b 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -507,6 +507,13 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>   					source->dev->name);
>   		} else {
>   			/* fastpath: update of existing entry */
> +			if (source->port_no != fdb->dst->port_no &&
> +				net_ratelimit())
> +				br_warn(br, "Port flapping detected source entry dev = %s mac = %pM, port_no = %d\n existing entry dev = %s mac = %pM, port_no = %d\n",
> +					source->dev->name,
> +					addr, source->port_no,
> +					fdb->dst->dev->name, addr,

    Why print the same MAC address twice?

> +					fdb->dst->port_no);
>   			fdb->dst = source;
>   			fdb->updated = jiffies;
>   			if (unlikely(added_by_user))

WBR, Sergei
