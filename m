From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 09:27:12 +0100
Message-ID: <49AF8CE0.6030301@trash.net>
References: <49AF79A6.6030002@trash.net>	<20090304.231120.86999183.davem@davemloft.net>	<49AF7B72.2020905@trash.net> <20090304.231911.213286076.davem@davemloft.net> <49AF7E93.2010800@trash.net> <49AF7FD3.5010709@trash.net> <49AF87D6.5040104@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bart@jukie.net,
	greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755312AbZCEI11@vger.kernel.org>
In-Reply-To: <49AF87D6.5040104@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Blaschka wrote:
> Hi Dave, Patrick,
>
> sorry I could not follow the complete discussion of the fixes done for this problem
> but does
>
>  	if (netif_device_present(real_dev) && ops->ndo_neigh_setup)
> -		err = ops->ndo_neigh_setup(dev, pa);
> +		err = ops->ndo_neigh_setup(real_dev, pa);
>
> not change the idea of the neigh_setup? Remind we want the neigh_setup of the
> real device as the neigh setup function for the vlan device.
>   

An we still use it. The only difference is that we pass it the
correct device reference, which not only fixes the recursion,
but is also expected by the callbacks. Look at bonding or simply
vlan itself.

The setup itself is still done using the neigh_params passed to
VLAN, which appears to be what was originally intended.
