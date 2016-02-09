From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for
 RNDIS_STATUS_NETWORK_CHANGE
Date: Tue, 09 Feb 2016 05:04:38 -0500 (EST)
Message-ID: <20160209.050438.1204672612521151525.davem@davemloft.net>
References: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
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

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue,  2 Feb 2016 16:15:56 -0800

> We simulates a link down period for RNDIS_STATUS_NETWORK_CHANGE message to
> trigger DHCP renew. User daemons may need multiple seconds to trigger the
> link down event. (e.g. ifplugd: 5sec, network-manager: 4sec.) So update
> this link down period to 10 sec to properly trigger DHCP renew.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Two things look really bad about this to me:

1) Any value you choose is arbitrary.  If some new network configuration daemon
   is slower, you will have to change this value again.

   This is _NOT_ sustainable in the long term.

2) It is completely unclear to me why this driver needs to delay at all or
   wait for anything.  I see no other driver having to deal with this issue.

Until you address both of these points I am not going to apply this patch.

Thanks.
