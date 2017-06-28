From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/2] vxlan: change vxlan_validate() to use
 netlink_ext_ack for error reporting
Date: Wed, 28 Jun 2017 19:18:01 +0200
Message-ID: <20170628191801.1bc8ed67@griffin>
References: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, roopa@cumulusnetworks.com, pshelar@ovn.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2017 22:47:57 +0200, Matthias Schiffer wrote:
>  		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS]))) {
> -			pr_debug("invalid all zero ethernet address\n");
> +			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_ADDRESS],
> +					    "invalid ethernet address");

Could we be more specific here? This is better than nothing but still
not as helpful to the user as it could be. What about something like
"the provided ethernet address is not unicast"?

> -		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU)
> +		if (mtu < ETH_MIN_MTU || mtu > ETH_MAX_MTU) {
> +			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_MTU],
> +					    "invalid MTU");

"MTU must be between 68 and 65535"

> -		if (id >= VXLAN_N_VID)
> +		if (id >= VXLAN_N_VID) {
> +			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_VXLAN_ID],
> +					    "invalid VXLAN ID");

"VXLAN ID must be lower than 16777216"

>  		if (ntohs(p->high) < ntohs(p->low)) {
> -			pr_debug("port range %u .. %u not valid\n",
> -				 ntohs(p->low), ntohs(p->high));
> +			NL_SET_ERR_MSG_ATTR(extack, data[IFLA_VXLAN_PORT_RANGE],
> +					    "port range not valid");

Since you're getting rid of the values output, I'd rather suggest more
explicit "the first value of the port range must not be higher than the
second value" or so. Shorter wording is welcome :-)

Thanks,

 Jiri
