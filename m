From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/2] vxlan: add back error messages to
 vxlan_config_validate() as extended netlink acks
Date: Wed, 28 Jun 2017 19:25:26 +0200
Message-ID: <20170628192526.2b7e4958@griffin>
References: <f2c1ed0d8e70a1d2bc900f0dd4b5a93f4df5a3e3.1498595233.git.mschiffer@universe-factory.net>
        <b190d4e8bb6a90a00105473287b19e09ad8c4c58.1498595233.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, roopa@cumulusnetworks.com, pshelar@ovn.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b190d4e8bb6a90a00105473287b19e09ad8c4c58.1498595233.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2017 22:47:58 +0200, Matthias Schiffer wrote:
>  		if ((conf->flags & ~VXLAN_F_ALLOWED_GPE) ||
>  		    !(conf->flags & VXLAN_F_COLLECT_METADATA)) {
> +			NL_SET_ERR_MSG(extack,
> +				       "unsupported combination of extensions");

Since we're redesigning this, let's be more helpful to the user.
There's probably not going to be tremendous improvements here but let's
try at least a bit.

"VXLAN GPE does not support this combination of extensions"

>  			if (local_type & IPV6_ADDR_LINKLOCAL) {
>  				if (!(remote_type & IPV6_ADDR_LINKLOCAL) &&
> -				    (remote_type != IPV6_ADDR_ANY))
> +				    (remote_type != IPV6_ADDR_ANY)) {
> +					NL_SET_ERR_MSG(extack,
> +						       "invalid combination of address scopes");

"invalid combination of local and remote address scopes"

>  					return -EINVAL;
> +				}
>  
>  				conf->flags |= VXLAN_F_IPV6_LINKLOCAL;
>  			} else {
>  				if (remote_type ==
> -				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL))
> +				    (IPV6_ADDR_UNICAST | IPV6_ADDR_LINKLOCAL)) {
> +					NL_SET_ERR_MSG(extack,
> +						       "invalid combination of address scopes");

ditto

The rest looks good to me. Thanks a lot for doing the work, Matthias!

 Jiri
