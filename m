From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: please pull from git://lost.foo-projects.org/~ahkok/git/netdev-2.6
 upstream-fixes
Date: Tue, 24 Oct 2006 14:43:55 -0700
Message-ID: <453E891B.5030602@intel.com>
References: <20061017190139.4194.20128.stgit@gitlost.site> <453A6769.4000305@pobox.com> <453CDC00.2020705@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29484 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1422646AbWJXVqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 17:46:15 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <453CDC00.2020705@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Jeff Garzik wrote:
>> Kok, Auke wrote:
>>> Hi,
>>>
>>> The following fixes targeted to netdev-2.6#upstream-fixes are available
>>> through git:
>>>
>>> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 
>>> upstream-fixes
>>
>> hrm.  since another e100 fixes got applied, can you either (a) update 
>> the above URL for that change, or (b) provide separate e100 and e1000 
>> pull urls?
> 
> I dropped the e100 patch from the series, it now contains (at the above 
> url) only the e1000 changes.

okay, I've rebased the trees on the latest upstream-fixes and master from netdev-2.6, 
and on top of that added the latest e100 shutdown patch to it (see below).

Jeff,

Please pull from git://lost.foo-projects.org/~ahkok/git/netdev-2.6
  upstream-fixes in to your #upstream-fixes or #upstream-linus branch so that these 
fixes get into 2.6.19.

Thanks.

Auke


---

e100: account for closed interface when shutting down

From: Auke Kok <auke-jan.h.kok@intel.com>

Account for the interface being closed before disabling polling
on a device, to fix shutdown on some systems that explcitly close
the netdevice before calling shutdown.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

  drivers/net/e100.c |   10 ++++++++--
  1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index a3a08a5..19ab344 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2719,7 +2719,10 @@ static int e100_suspend(struct pci_dev *
  	struct net_device *netdev = pci_get_drvdata(pdev);
  	struct nic *nic = netdev_priv(netdev);

-	netif_poll_disable(nic->netdev);
+#ifdef CONFIG_E100_NAPI
+	if (netif_running(netdev))
+		netif_poll_disable(nic->netdev);
+#endif
  	del_timer_sync(&nic->watchdog);
  	netif_carrier_off(nic->netdev);

@@ -2763,7 +2766,10 @@ static void e100_shutdown(struct pci_dev
  	struct net_device *netdev = pci_get_drvdata(pdev);
  	struct nic *nic = netdev_priv(netdev);

-	netif_poll_disable(nic->netdev);
+#ifdef CONFIG_E100_NAPI
+	if (netif_running(netdev))
+		netif_poll_disable(nic->netdev);
+#endif
  	del_timer_sync(&nic->watchdog);
  	netif_carrier_off(nic->netdev);
