From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 08/10] hv_netvsc: Don't ask for additional head
 room in the skb
Date: Tue, 24 Nov 2015 16:27:52 +0000
Message-ID: <BLUPR0301MB165134BACEE74BCBD6581F78A0060@BLUPR0301MB1651.namprd03.prod.outlook.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-8-git-send-email-kys@microsoft.com>
 <87vb8rlqrv.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87vb8rlqrv.fsf@vitty.brq.redhat.com>
Content-Language: en-US
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



> -----Original Message-----
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Tuesday, November 24, 2015 12:56 AM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH net-next 08/10] hv_netvsc: Don't ask for additional head
> room in the skb
> 
> "K. Y. Srinivasan" <kys@microsoft.com> writes:
> 
> > The rndis header is 116 bytes big and can be placed in the default
> > head room that will be available in the skb.
> 
> We have the following in include/linux/netdevice.h:
> 
> #if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
> # if defined(CONFIG_MAC80211_MESH)
> #  define LL_MAX_HEADER 128
> # else
> #  define LL_MAX_HEADER 96
> # endif
> #else
> # define LL_MAX_HEADER 32
> #endif
> 
> In case someone disables MAC80211_MESH in his kernel config we're in
> troubles again. I suggest we add additional patch here making sure it is
> 128 bytes for Hyper-V:
> 
> #if defined(CONFIG_HYPERV_NET)
> # define LL_MAX_HEADER 128
> #elseif defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
> ...

Thanks Vitaly; will do.

K. Y
