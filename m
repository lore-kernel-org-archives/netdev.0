From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vsock: only load vmci transport on VMware hypervisor
 by default
Date: Thu, 17 Aug 2017 10:04:01 -0700 (PDT)
Message-ID: <20170817.100401.864010589587308706.davem@davemloft.net>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, jasowang@redhat.com, georgezhang@vmware.com,
 sthemmin@microsoft.com, rolf.neugebauer@docker.com,
 marcelo.cerri@canonical.com, asias@redhat.com, dan.carpenter@oracle.com,
 olaf@aepfle.de, haiyangz@microsoft.com, dave.scott@docker.com,
 stefanha@redhat.com, apw@canonical.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, joe@perches.com,
 devel@linuxdriverproject.org, vkuznets@redhat.com, jhansen@vmware.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Thu, 17 Aug 2017 08:00:29 +0000

> @@ -73,6 +74,10 @@ struct vmci_transport_recv_pkt_info {
>  	struct vmci_transport_packet pkt;
>  };
>  
> +static bool skip_hypervisor_check;
> +module_param(skip_hypervisor_check, bool, 0444);
> +MODULE_PARM_DESC(hot_add, "If set, attempt to load on non-VMware platforms");
> +

I would avoid module parameters at all costs.

It is the worst possible interface for users of your software.

You really need to fundamentally solve the problems related to making
sure the proper modules for the VM actually present on the system get
loaded when necessary rather than adding hacks like this.

Unlike a proper solution, these hacks are ugly but have to stay around
forever once you put them in place.
