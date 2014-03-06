From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] Drivers: net: hyperv: Enable send side checksum
 offload
Date: Thu, 06 Mar 2014 14:33:54 -0500 (EST)
Message-ID: <20140306.143354.1296864763659469552.davem@davemloft.net>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-5-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394104390-23477-5-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Thu,  6 Mar 2014 03:13:09 -0800

> +bool get_net_transport_info(struct sk_buff *skb, bool *is_v4,
> +				bool *is_tcp, bool *is_udp, u32 *trans_off)
> +{

Returning so many values like this is awkward, at best.

Why not return a well defined bitmask:

#define TRANSPORT_INFO_SUCCESS	0x00000001
#define TRANSPORT_INFO_TCP	0x00000002
#define TRANSPORT_INFO_UDP	0x00000004

Then the only value you have to return by reference is trans_off.
