From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] PCI: fix the return value for the
 pci_find_pcie_root_port()
Date: Thu, 17 Aug 2017 21:38:02 +0800
Message-ID: <7b19e5fe-e6b8-e51d-53a3-0f9ee328a842@huawei.com>
References: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
 <20170817105156.GA18789@ulmo>
 <ea83e7a8-39a4-5b94-1148-5bf4ae4ed214@huawei.com>
 <20170817133012.GC6854@ulmo>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, gabriele.paoloni@huawei.com, asit.k.mallick@intel.com,
 catalin.marinas@arm.com, will.deacon@arm.com, linuxarm@huawei.com,
 alexander.duyck@gmail.com, ashok.raj@intel.com, eric.dumazet@gmail.com,
 helgaas@kernel.org, jeffrey.t.kirsher@intel.com, linux-pci@vger.kernel.org,
 ganeshgr@chelsio.com, Bob.Shaw@amd.com, leedom@chelsio.com,
 patrick.j.cramer@intel.com, bhelgaas@google.com, werner@chelsio.com,
 linux-arm-kernel@lists.infradead.org, amira@mellanox.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, David.Laight@aculab.com,
 Suravee.Suthikulpanit@amd.com, robin.murphy@arm.com, davem@davemloft.net,
 l.stach@pengutronix.de
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170817133012.GC6854@ulmo>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 2017/8/17 21:30, Thierry Reding wrote:
> On Thu, Aug 17, 2017 at 08:40:16PM +0800, Ding Tianhong wrote:
>>
>>
>> On 2017/8/17 18:51, Thierry Reding wrote:
>>> On Thu, Aug 17, 2017 at 10:25:30AM +0800, Ding Tianhong wrote:
>>>> The pci_find_pcie_root_port() would return NULL if the given
>>>> dev is already a Root Port, it looks like unfriendly to the
>>>> PCIe Root Port device, Thierry and Bjorn suggest to let this
>>>> function return the given dev under this circumstances.
>>>>
>>>> Fixes: 0e405232871d6 ("PCI: fix oops when try to find Root Port for a PCI device")
>>>> Suggested-by: Thierry Reding <thierry.reding@gmail.com>
>>>> Suggested-by: Bjorn Helgaas <helgaas@kernel.org>
>>>> Signed-off-by: Thierry Reding <thierry.reding@gmail.com>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>> ---
>>>>  drivers/pci/pci.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
>>>> index 7e2022f..352bb53 100644
>>>> --- a/drivers/pci/pci.c
>>>> +++ b/drivers/pci/pci.c
>>>> @@ -514,7 +514,7 @@ struct resource *pci_find_resource(struct pci_dev *dev, struct resource *res)
>>>>   */
>>>>  struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
>>>>  {
>>>> -	struct pci_dev *bridge, *highest_pcie_bridge = NULL;
>>>> +	struct pci_dev *bridge, *highest_pcie_bridge = dev;
>>>>  
>>>>  	bridge = pci_upstream_bridge(dev);
>>>>  	while (bridge && pci_is_pcie(bridge)) {
>>>
>>> I think this should actually be this change on top of a revert of commit
>>> 0e405232871d6 ("PCI: fix oops when try to find Root Port for a PCI
>>> device"). After the above change, the previous fix will have a redundant
>>> check because highest_pcie_bridge will never be NULL.
>>>
>>> Let me send out that version to clarify what I mean.
>>>
>>
>> Hi Thierry:
>>
>> The patch ("PCI: fix oops when try to find Root Port for a PCI device")
>> has been merge to the linus mainline tree before you found this deficiencies....
> 
> I understand that. I'm just saying that there's no point keeping that
> change around because it no longer makes sense after we initialize the
> highest_pcie_bridge variable to dev.
> 

Ok, NO problem.:)

> Thierry
> 
