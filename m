From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net v2 5/5] hv_netvsc: fix bonding devices check in
 netvsc_netdev_event()
Date: Mon, 15 Aug 2016 15:54:55 +0000
Message-ID: <DM5PR03MB2538F9629FA09B6E3BE4FC5ECA120@DM5PR03MB2538.namprd03.prod.outlook.com>
References: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
 <1471276123-24264-6-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471276123-24264-6-git-send-email-vkuznets@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Monday, August 15, 2016 11:49 AM
> To: netdev@vger.kernel.org
> Cc: devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; Haiyang
> Zhang <haiyangz@microsoft.com>; KY Srinivasan <kys@microsoft.com>;
> Stephen Hemminger <stephen@networkplumber.org>
> Subject: [PATCH net v2 5/5] hv_netvsc: fix bonding devices check in
> netvsc_netdev_event()
> 
> Bonding driver sets IFF_BONDING on both master (the bonding device) and
> slave (the real NIC) devices and in netvsc_netdev_event() we want to skip
> master devices only. Currently, there is an uncertainty when a slave
> interface is removed: if bonding module comes first in netdev_chain it
> clears IFF_BONDING flag on the netdev and netvsc_netdev_event()
> correctly
> handles NETDEV_UNREGISTER event, but in case netvsc comes first on the
> chain it sees the device with IFF_BONDING still attached and skips it. As
> we still hold vf_netdev pointer to the device we crash on the next inject.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Thanks!

Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
