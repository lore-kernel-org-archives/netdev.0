From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next v4 2/2] bridge: vlan: signal if
 anything changed on vlan add
Date: Thu, 26 Oct 2017 19:16:27 +0900
Message-ID: <622bf4ff-e493-58f0-bedf-8183a82e8772@lab.ntt.co.jp>
References: <f6c0da96-77f0-db19-7a9a-13b246d83d39@cumulusnetworks.com>
	<1508971954-3567-1-git-send-email-nikolay@cumulusnetworks.com>
	<1508971954-3567-3-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, mrv@mojatatu.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1508971954-3567-3-git-send-email-nikolay@cumulusnetworks.com>
Content-Language: en-US
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

On 2017/10/26 7:52, Nikolay Aleksandrov wrote:
...
> @@ -559,6 +574,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
>  
>  	ASSERT_RTNL();
>  
> +	*changed = false;
>  	vg = br_vlan_group(br);
>  	vlan = br_vlan_find(vg, vid);
>  	if (vlan) {
> @@ -576,9 +592,12 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
>  			refcount_inc(&vlan->refcnt);
>  			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
>  			vg->num_vlans++;
> +			*changed = true;
>  		}
> -		__vlan_add_flags(vlan, flags);
> -		return 0;
> +		if (__vlan_add_flags(vlan, flags))
> +			*changed = true;
> +
> +		return ret;

"ret" isn't always initialized here, is it?


Toshiaki Makita
