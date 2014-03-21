From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] bonding: Inactive slaves should keep inactive flag's
 value to 1.
Date: Fri, 21 Mar 2014 14:34:23 +0300
Message-ID: <532C23BF.4040208@cogentembedded.com>
References: <1395305504-29973-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com
To: Zheng Li <zheng.x.li@oracle.com>, netdev@vger.kernel.org,
	fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395305504-29973-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/20/2014 11:51 AM, Zheng Li wrote:

> Except bond mode 1, in other bond modes, inactive slaves should keep inactive flag to
> 1 to refuse to receive broadcast packets. Now, active slave send broadcast packets
> (for example ARP requests) which will arrive inactive slaves on same host from switch,
> but inactive slave's inactive flag is zero that cause bridge receive the broadcast
> packets to produce a wrong entry in forward table. Typical situation is domu send some
> ARP request which go out from dom0 bond's active slave, then the ARP broadcast request
> packets go back to inactive slave from switch, because the inactive slave's inactive
> flag is zero, kernel will receive the packets and pass them to bridge, that cause dom0's
> bridge map domu's MAC address to port of bond, bridge should map domu's MAC to port of vif.

> Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
> ---
>   drivers/net/bonding/bond_main.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index e5628fc..2f73f18 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3063,7 +3063,7 @@ static int bond_open(struct net_device *bond_dev)
>   				bond_set_slave_inactive_flags(slave,
>   							      BOND_SLAVE_NOTIFY_NOW);
>   			} else {
> -				bond_set_slave_active_flags(slave,
> +				bond_set_slave_state(slave, BOND_STATE_ACTIVE,
>   							    BOND_SLAVE_NOTIFY_NOW);

    Now you have to re-indent this line to start right under 'state'.

WBR, Sergei
