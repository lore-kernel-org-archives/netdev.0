From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v10 04/22] IB/hns: Add RoCE engine reset function
Date: Tue, 28 Jun 2016 14:31:41 +0800
Message-ID: <577219CD.2000604@huawei.com>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-5-git-send-email-oulijun@huawei.com>
 <20160624145938.GE23995@leon.nu> <576E5C21.5030904@huawei.com>
 <20160627080122.GA3584@leon.nu> <5770E465.1070702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5770E465.1070702-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2016/6/27 16:31, oulijun wrote:
> Hi, Leon
> =E5=9C=A8 2016/6/27 16:01, Leon Romanovsky =E5=86=99=E9=81=93:
>> On Sat, Jun 25, 2016 at 06:25:37PM +0800, Wei Hu (Xavier) wrote:
>>>
>>> On 2016/6/24 22:59, Leon Romanovsky wrote:
>>>> On Thu, Jun 16, 2016 at 10:35:12PM +0800, Lijun Ou wrote:
>>>>> This patch mainly added reset flow of RoCE engine in RoCE
>>>>> driver. It is necessary when RoCE is loaded and removed.
>>>>>
>>>>> Signed-off-by: Wei Hu <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>>> Signed-off-by: Nenglong Zhao <zhaonenglong-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
>>>>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>>>> ---
>> ...
>>
>>>>> +
>>>>> +#define SLEEP_TIME_INTERVAL				20
>>>>> +
>>>>> +extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode=
, bool enable);
>>>> Why did you add this extern?
>>>> You already exported this function.
>>>> drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c:EXPORT_SYMBOL(h=
ns_dsaf_roce_reset);
>>> Hi, Leon
>>>
>>>          The function named hns_dsaf_roce_reset is defined in hns_d=
saf_main.c
>>>          It exists in hns_dsaf.ko(ethernet driver)
>>>
>>>          RoCE driver will call this function.
>>>
>>>          Your suggestion is that delete "extern" as below:
>>>              In /drivers/infiniband/hw/hns/hns_roce_hw_v1.h:
>>>
>>>            int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnod=
e, bool
>>> enable);
>>>
>>> Right? or other soultion?
>> You placed it in header file.
>> Please move it to your hns_roce_hw_v1.c file.
>>
>   You suggest to do as follows, right?
>   in hns_roce_hw_v1.c
>     int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool e=
nable);
>
>   and delete the keyword extern
>
>   Bcause reserve the extern in hns_roce_hw_v1.c, the checkpatch is no=
t pass.
Hi, Leon & Doug Ledford

     If we move it to hns_roce_hw_v1.c file as below:
         int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, boo=
l=20
enable);
     The result of checkpatch is warning.

     We prepare to add a head file for this function as below:
         In the directory of include\linux,  mkdir hns.
         add hns_driver.h in include\linux\hns.
         In the file of hns_driver.h, the declaration:
                int hns_dsaf_roce_reset(struct fwnode_handle=20
*dsaf_fwnode, bool enable);
     What do you think about?


Regards
Wei Hu
>>>
>>> Regards
>>> Wei Hu
>>>>> +
>>>>> +#endif
>>>>> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/=
infiniband/hw/hns/hns_roce_main.c
>>>>> index 8924ce3..d5ccce2 100644
>>>>> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
>>>>> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
>>>>> @@ -71,7 +71,9 @@ static int hns_roce_get_cfg(struct hns_roce_dev=
 *hr_dev)
>>>>>   	struct platform_device *pdev =3D NULL;
>>>>>   	struct resource *res;
>>>>> -	if (!of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
>>>>> +	if (of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
>>>>> +		hr_dev->hw =3D &hns_roce_hw_v1;
>>>>> +	} else {
>>>>>   		dev_err(dev, "device no compatible!\n");
>>>>>   		return -EINVAL;
>>>>>   	}
>>>>> @@ -118,6 +120,11 @@ static int hns_roce_get_cfg(struct hns_roce_=
dev *hr_dev)
>>>>>   	return 0;
>>>>>   }
>>>>> +static int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bo=
ol enable)
>>>>> +{
>>>>> +	return hr_dev->hw->reset(hr_dev, enable);
>>>>> +}
>>>>> +
>>>>>   /**
>>>>>   * hns_roce_probe - RoCE driver entrance
>>>>>   * @pdev: pointer to platform device
>>>>> @@ -156,6 +163,12 @@ static int hns_roce_probe(struct platform_de=
vice *pdev)
>>>>>   		goto error_failed_get_cfg;
>>>>>   	}
>>>>> +	ret =3D hns_roce_engine_reset(hr_dev, true);
>>>> Do you have better solution to sense device without doing full res=
et of
>>>> your hardware?
>>> Hi, Leon
>>>
>>>      In this place, we need reset RoCEE engine to ensure that RoCE =
engine can
>>> work correctly.
>>>      Hip06 Soc only support full reset RoCEE engine.
>>>
>>> Regards
>>> Wei Hu
>>>
>>>>> +	if (ret) {
>>>>> +		dev_err(dev, "Reset roce engine failed!\n");
>>>>> +		goto error_failed_get_cfg;
>>>>> +	}
>>>>> +
>>>>>   error_failed_get_cfg:
>>>>>   	ib_dealloc_device(&hr_dev->ib_dev);
>>>>> @@ -170,6 +183,8 @@ static int hns_roce_remove(struct platform_de=
vice *pdev)
>>>>>   {
>>>>>   	struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
>>>>> +	(void)hns_roce_engine_reset(hr_dev, false);
>>>> Any reason to do explicit casting?
>>> Hi, Leon
>>>
>>> /**
>>>   * hns_roce_engine_reset - reset roce
>>>   * @hr_dev: roce device struct pointer
>>>   * @enable: true -- drop reset, false -- reset
>>>   * return 0 - success , negative --fail
>>>   */
>>> static int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bool =
enable);
>>>
>>> hns_roce_engine_reset->hns_roce_v1_reset->hns_dsaf_roce_reset
>>>
>>> The err branch of hns_roce_engine_reset as below=EF=BC=9A
>>> int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool ena=
ble)
>>> {
>>>      <...>
>>>      if (!is_of_node(dsaf_fwnode)) {
>>>          pr_err("hisi_dsaf: Only support DT node!\n");
>>>          return -EINVAL;
>>>      }
>>>
>>>      pdev =3D of_find_device_by_node(to_of_node(dsaf_fwnode));
>>>      dsaf_dev =3D dev_get_drvdata(&pdev->dev);
>>>      if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
>>>          dev_err(dsaf_dev->dev, "%s v1 chip do not support roce!\n"=
,
>>>              dsaf_dev->ae_dev.name);
>>>          return -ENODEV;
>>>      }
>>>      <...>
>>> }
>>>
>>>     When the cpu is processing hns_roce_engine_reset(hr_dev, false)=
,
>>> hns_roce_engine_reset(hr_dev, true)  have been alomost processed
>>> sucessfully.
>>>     From the err branch of hns_roce_engine_reset, we found at this =
time
>>> hns_roce_engine_reset(hr_dev, true) could not return err.
>>>
>>> In hns_roce_remove function, we call hns_roce_engine_reset(hr_dev, =
false),
>>> and doesn't need to judge the return value.
>> Do you see any compilation warning for this part of code?
>>
>>      struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
>> +   hns_roce_engine_reset(hr_dev, false);
>>
>> instead of
>>
>>      struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
>> +   (void)hns_roce_engine_reset(hr_dev, false);
>>
> No warning.
> However, the result of PClint checking is error, because the hns_roce=
_engine_reset have return value.
>
> thanks
> Lijun Ou
>
>
>
> .
>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
