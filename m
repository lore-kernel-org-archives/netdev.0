From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 8/8] bridge: Automatically manage
 promisc mode when vlan filtering is on.
Date: Thu, 15 May 2014 00:41:06 +0400
Message-ID: <5373D4E2.1070904@cogentembedded.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
	<1400080168-16625-9-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400080168-16625-9-git-send-email-vyasevic@redhat.com>
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

Hello.

On 05/14/2014 07:09 PM, Vlad Yasevich wrote:

> If the user doesn't enable vlan filtering, we have to place all
> bridge ports in promsic mode so that we retain the capability of
> of receiving tagged frames.
> When vlan filtering is enabled, the each port will be provided with
> necessary vlan configuration and would be able to receive tagged
> traffic without promiscuous mode set, thus allowing us to automatically
> turn promiscuity on or off depending on the configuration.

> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   net/bridge/br_if.c      | 12 ++++++++----
>   net/bridge/br_private.h |  9 +++++++++
>   net/bridge/br_vlan.c    |  1 +
>   3 files changed, 18 insertions(+), 4 deletions(-)

> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 7759144..a9bf8cc 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -131,12 +131,16 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
>   void br_manage_promisc(struct net_bridge *br)
>   {
>   	struct net_bridge_port *p;
> +	int set_all = false;

    s/int/bool/?

[...]

WBR, Sergei
