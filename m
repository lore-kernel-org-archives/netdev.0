From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v3 net-next 1/3] bridge: Add a default_pvid
	sysfs attribute
Date: Fri, 03 Oct 2014 10:08:10 +0900
Message-ID: <542DF6FA.4050107@lab.ntt.co.jp>
References: <1412294070-11930-1-git-send-email-vyasevic@redhat.com>
	<1412294070-11930-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1412294070-11930-2-git-send-email-vyasevic@redhat.com>
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

On 2014/10/03 8:54, Vladislav Yasevich wrote:
> This patch allows the user to set and retrieve default_pvid
> value.  A new value can only be stored when vlan filtering
> is disabled.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
...
> +int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
> +{
> +	u16 pvid = val;
> +	int err = 0;
> +
> +	if (!val || val >= VLAN_VID_MASK)
> +		return -EINVAL;
> +
> +	if (!rtnl_trylock())
> +		return restart_syscall();
> +
> +	if (pvid == br->default_pvid)
> +		goto unlock;
> +
> +	/* Only allow default pvid change when filtering is disabled */
> +	if (br->vlan_enabled) {
> +		pr_info_once("Please disable vlan filtering to change default_pvid\n");
> +		err = -EPERM;
> +		goto unlock;
> +	}
> +
> +	br->default_pvid = vid;

typo: s/vid/pvid/

Thanks,
Toshiaki Makita
