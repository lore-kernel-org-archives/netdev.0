From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 1/4] net: Add support for hardware-offloaded
 encapsulation
Date: Fri, 7 Dec 2012 10:07:27 +0000
Message-ID: <1354874847.20838.49.camel@deadeye.wl.decadent.org.uk>
References: <1354845419-22483-1-git-send-email-joseph.gasparakis@intel.com>
	 <1354845419-22483-2-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <shemminger@vyatta.com>,
	<chrisw@sous-sol.org>, <gospo@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dmitry@broadcom.com>, <saeed.bishara@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354845419-22483-2-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-12-06 at 17:56 -0800, Joseph Gasparakis wrote:
> This patch adds support in the kernel for offloading in the NIC Tx and Rx
> checksumming for encapsulated packets (such as VXLAN and IP GRE).
[...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1063,6 +1063,8 @@ struct net_device {
>  	netdev_features_t	wanted_features;
>  	/* mask of features inheritable by VLAN devices */
>  	netdev_features_t	vlan_features;
> +	/* mask of features inherited by encapsulating devices */
> +	netdev_features_t	hw_enc_features;
[...]

How will the networking core know *which* encapsulations this applies
to?  I notice that your implementation in ixgbe does not set
NETIF_F_HW_CSUM here, so presumably the hardware will parse headers to
find which ranges should be checksummed and it won't cover the next
encapsulation protocol that comes along.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
