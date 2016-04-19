From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 1/1] drivers: net: cpsw: Prevent NUll pointer
 dereference with two PHYs
Date: Tue, 19 Apr 2016 21:44:09 +0300
Message-ID: <57167C79.20205@ti.com>
References: <1461074186-25535-1-git-send-email-andrew.goodbody@cambrionix.com>
 <1461074186-25535-2-git-send-email-andrew.goodbody@cambrionix.com>
 <57164383.6080103@ti.com>
 <20160419110140.75e35c3c.drivshin.allworx@gmail.com> <57165269.40207@ti.com>
 <20160419131443.7a3b3ef7.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <mugunthanvnm@ti.com>,
	<tony@atomide.com>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39053 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932799AbcDSSoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:44:25 -0400
In-Reply-To: <20160419131443.7a3b3ef7.drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2016 08:14 PM, David Rivshin (Allworx) wrote:
> On Tue, 19 Apr 2016 18:44:41 +0300
> Grygorii Strashko <grygorii.strashko@ti.com> wrote:
>
>> On 04/19/2016 06:01 PM, David Rivshin (Allworx) wrote:
>>> On Tue, 19 Apr 2016 17:41:07 +0300
>>> Grygorii Strashko <grygorii.strashko@ti.com> wrote:
>>>
>>>> Hi,
>>>>
>>>> On 04/19/2016 04:56 PM, Andrew Goodbody wrote:
>>>>> Adding a 2nd PHY to cpsw results in a NULL pointer dereference
>>>>> as below. Fix by maintaining a reference to each PHY node in slave
>>>>> struct instead of a single reference in the priv struct which was
>>>>> overwritten by the 2nd PHY.
>>>>
>>>> David, Is it possible to drop prev version of this patch from linux-next
>>>> - it breaks boot on many TI boards with -next.
>>>>
>>>>
>>>>>
>>>>> [   17.870933] Unable to handle kernel NULL pointer dereference at virtual address 00000180
>>>>> [   17.879557] pgd = dc8bc000
>>>>> [   17.882514] [00000180] *pgd=9c882831, *pte=00000000, *ppte=00000000
>>>>> [   17.889213] Internal error: Oops: 17 [#1] ARM
>>>>> [   17.893838] Modules linked in:
>>>>> [   17.897102] CPU: 0 PID: 1657 Comm: connmand Not tainted 4.5.0-ge463dfb-dirty #11
>>>>> [   17.904947] Hardware name: Cambrionix whippet
>>>>> [   17.909576] task: dc859240 ti: dc968000 task.ti: dc968000
>>>>> [   17.915339] PC is at phy_attached_print+0x18/0x8c
>>>>> [   17.920339] LR is at phy_attached_info+0x14/0x18
>>>>> [   17.925247] pc : [<c042baec>]    lr : [<c042bb74>]    psr: 600f0113
>>>>> [   17.925247] sp : dc969cf8  ip : dc969d28  fp : dc969d18
>>>>> [   17.937425] r10: dda7a400  r9 : 00000000  r8 : 00000000
>>>>> [   17.942971] r7 : 00000001  r6 : ddb00480  r5 : ddb8cb34  r4 : 00000000
>>>>> [   17.949898] r3 : c0954cc0  r2 : c09562b0  r1 : 00000000  r0 : 00000000
>>>>> [   17.956829] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
>>>>> [   17.964401] Control: 10c5387d  Table: 9c8bc019  DAC: 00000051
>>>>> [   17.970500] Process connmand (pid: 1657, stack limit = 0xdc968210)
>>>>> [   17.977059] Stack: (0xdc969cf8 to 0xdc96a000)
>>>>
>>>> [...]
>>>>
>>>>> [   18.323956] [<c05e4cb8>] (inet_ioctl) from [<c055f5ac>] (sock_ioctl+0x15c/0x2d8)
>>>>> [   18.331829] [<c055f450>] (sock_ioctl) from [<c010b388>] (do_vfs_ioctl+0x98/0x8d0)
>>>>> [   18.339765]  r7:00008914 r6:dc8ab4c0 r5:dd257ae0 r4:beaeda20
>>>>> [   18.345822] [<c010b2f0>] (do_vfs_ioctl) from [<c010bc34>] (SyS_ioctl+0x74/0x84)
>>>>> [   18.353573]  r10:00000000 r9:00000011 r8:beaeda20 r7:00008914 r6:dc8ab4c0 r5:dc8ab4c0
>>>>> [   18.361924]  r4:00000000
>>>>> [   18.364653] [<c010bbc0>] (SyS_ioctl) from [<c00163e0>] (ret_fast_syscall+0x0/0x3c)
>>>>> [   18.372682]  r9:dc968000 r8:c00165e8 r7:00000036 r6:00000002 r5:00000011 r4:00000000
>>>>> [   18.380960] Code: e92dd810 e24cb010 e24dd010 e59b4004 (e5902180)
>>>>> [   18.387580] ---[ end trace c80529466223f3f3 ]---
>>>>
>>>> ^ Could you make it shorter and drop timestamps, pls?
>>>>
>>>>>
>>>>> Signed-off-by: Andrew Goodbody <andrew.goodbody@cambrionix.com>
>>>>> ---
>>>>>
>>>>> v2 - Move allocation of memory for priv->slaves to inside cpsw_probe_dt so it
>>>>>         has data->slaves initialised first which is needed to calculate size
>>>>>
>>>>>     drivers/net/ethernet/ti/cpsw.c | 30 +++++++++++++++---------------
>>>>>     1 file changed, 15 insertions(+), 15 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>>>>> index 42fdfd4..e62909c 100644
>>>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>>>> @@ -349,6 +349,7 @@ struct cpsw_slave {
>>>>>     	struct cpsw_slave_data		*data;
>>>>>     	struct phy_device		*phy;
>>>>>     	struct net_device		*ndev;
>>>>> +	struct device_node		*phy_node;
>>>>>     	u32				port_vlan;
>>>>>     	u32				open_stat;
>>>>>     };
>>>>> @@ -367,7 +368,6 @@ struct cpsw_priv {
>>>>>     	spinlock_t			lock;
>>>>>     	struct platform_device		*pdev;
>>>>>     	struct net_device		*ndev;
>>>>> -	struct device_node		*phy_node;
>>>>>     	struct napi_struct		napi_rx;
>>>>>     	struct napi_struct		napi_tx;
>>>>>     	struct device			*dev;
>>>>> @@ -1148,8 +1148,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>>>>>     		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
>>>>>     				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
>>>>>
>>>>> -	if (priv->phy_node)
>>>>> -		slave->phy = of_phy_connect(priv->ndev, priv->phy_node,
>>>>> +	if (slave->phy_node)
>>>>> +		slave->phy = of_phy_connect(priv->ndev, slave->phy_node,
>>>>>     				 &cpsw_adjust_link, 0, slave->data->phy_if);
>>>>>     	else
>>>>>     		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
>>>>> @@ -1946,7 +1946,7 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
>>>>>     	struct device_node *node = pdev->dev.of_node;
>>>>>     	struct device_node *slave_node;
>>>>>     	struct cpsw_platform_data *data = &priv->data;
>>>>> -	int i = 0, ret;
>>>>> +	int i, ret;
>>>>>     	u32 prop;
>>>>>
>>>>>     	if (!node)
>>>>> @@ -1958,6 +1958,14 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
>>>>>     	}
>>>>>     	data->slaves = prop;
>>>>>
>>>>> +	priv->slaves = devm_kzalloc(&pdev->dev,
>>>>> +				    sizeof(struct cpsw_slave) * data->slaves,
>>>>> +				    GFP_KERNEL);
>>>>> +	if (!priv->slaves)
>>>>> +		return -ENOMEM;
>>>>> +	for (i = 0; i < data->slaves; i++)
>>>>> +		priv->slaves[i].slave_num = i;
>>>>> +
>>>>>     	if (of_property_read_u32(node, "active_slave", &prop)) {
>>>>>     		dev_err(&pdev->dev, "Missing active_slave property in the DT.\n");
>>>>>     		return -EINVAL;
>>>>> @@ -2023,6 +2031,7 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
>>>>>     	if (ret)
>>>>>     		dev_warn(&pdev->dev, "Doesn't have any child node\n");
>>>>>
>>>>> +	i = 0;
>>>>>     	for_each_child_of_node(node, slave_node) {
>>>>>     		struct cpsw_slave_data *slave_data = data->slave_data + i;
>>>>>     		const void *mac_addr = NULL;
>>>>> @@ -2033,7 +2042,8 @@ static int cpsw_probe_dt(struct cpsw_priv *priv,
>>>>>     		if (strcmp(slave_node->name, "slave"))
>>>>>     			continue;
>>>>>
>>>>> -		priv->phy_node = of_parse_phandle(slave_node, "phy-handle", 0);
>>>>> +		priv->slaves[i].phy_node =
>>>>> +			of_parse_phandle(slave_node, "phy-handle", 0);
>>>>
>>>> i++?
>>>>
>>>> Ideally, the simplest way is to save phy_node in slave_data, but ...
>>>> (see comment below).
>>>
>>> FYI, I have a patch [1] that does exactly that in my queue. Sorry
>>> I've been busy and haven't had a chance to rebase/retest/resubmit
>>> since Nicolas gave his Tested-By (and I missed Andrew's original
>>> patch). I can probably steal some time to resurrect that quickly
>>> if it's preferred, just let me know.
>>>
>>> [1] http://www.spinics.net/lists/netdev/msg357772.html
>>
>> Ah Ok. There are no user of cpsw_platform_data outside of net/ethernet/ti/,
>> so yes, looks like your patch 1 does exactly what's needed.
>
> Given that the v1 of Andrew's patch is already in Dave's net tree, and
> would obviously have many conflicts with mine, how should I proceed?
> Since you already requested Dave revert that patch, should I just wait
> for that to happen and then resubmit my series?
>
> Dave, Does that sound good to you?
>

May be you can send revert + your patch 1 (only fix for this issue).


Dave, Does that sound good to you?

-- 
regards,
-grygorii
