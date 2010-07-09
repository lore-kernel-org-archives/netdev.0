From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH] igbvf: avoid name clash between PF and VF
Date: Fri, 09 Jul 2010 11:31:41 +0200
Message-ID: <4C36EC7D.5080800@redhat.com>
References: <4C2B0614.9040004@redhat.com> <201007081541.57685.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	Andy Gospodarek <gospo@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <201007081541.57685.arnd@arndb.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 08.07.2010 15:41, Arnd Bergmann wrote:
> On Wednesday 30 June 2010, Stefan Assmann wrote:
>> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
>> index 5e2b2a8..2fb665b 100644
>> --- a/drivers/net/igbvf/netdev.c
>> +++ b/drivers/net/igbvf/netdev.c
>> @@ -2787,7 +2787,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
>>         netif_carrier_off(netdev);
>>         netif_stop_queue(netdev);
>>
>> -       strcpy(netdev->name, "eth%d");
>> +       strcpy(netdev->name, "veth%d");
>>         err = register_netdev(netdev);
>>         if (err)
>>                 goto err_hw_init;
> 
> Note that 'veth' is the name used for a virtual ethernet pair by
> drivers/net/veth.c. If a variant of your patch gets applied, it would
> probably be useful to use a different naming scheme to avoid confusion
> with the veth driver.

Good point!
Greg suggested vfeth, that should be more descriptive and unique.

  Stefan
---
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 5e2b2a8..4d02af8 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2787,7 +2787,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);

-	strcpy(netdev->name, "eth%d");
+	strcpy(netdev->name, "vfeth%d");
 	err = register_netdev(netdev);
 	if (err)
 		goto err_hw_init;

------------------------------------------------------------------------------
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
