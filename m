From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [PATCH] [e1000] Lower the MSI unavailable message
	to INFO priority
Date: Thu, 17 May 2007 17:15:24 -0400
Message-ID: <464CC5EC.4020202@redhat.com>
References: <200705152359.l4FNxPcS018779@tazenda.hos.anvin.org>
	<464A512C.9080104@garzik.org> <464B229B.7060702@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	"H. Peter Anvin" <hpa@zytor.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <464B229B.7060702@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Jeff Garzik wrote:
>> H. Peter Anvin wrote:
>>> diff --git a/drivers/net/e1000/e1000_main.c
>>> b/drivers/net/e1000/e1000_main.c
>>> index 637ae8f..089ae3f 100644
>>> --- a/drivers/net/e1000/e1000_main.c
>>> +++ b/drivers/net/e1000/e1000_main.c
>>> @@ -307,7 +307,7 @@ static int e1000_request_irq(struct e1000_adapter
>>> *adapter)
>>>      if (adapter->hw.mac_type >= e1000_82571) {
>>>          adapter->have_msi = TRUE;
>>>          if ((err = pci_enable_msi(adapter->pdev))) {
>>> -            DPRINTK(PROBE, ERR,
>>> +            DPRINTK(PROBE, INFO,
>>>               "Unable to allocate MSI interrupt Error: %d\n", err);
>>>              adapter->have_msi = FALSE;
>>
>>
>> Actually, it should not print any message at all.
>>
>> pci_enable_msi() failure is a normal event (as you point out).  Even
>> at KERN_INFO level, the message is still misleading.
> 
> I've been reworking some of this code and there is even a
> pci_disable_msi() missing in case pci_request_irq failed. I'll post a
> patch to clean it up in a second.

It seems ixgb needs this too (the message removal at least?)



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
