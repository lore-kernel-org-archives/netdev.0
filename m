From: maowenan <maowenan@huawei.com>
Subject: Re: [PATCH] net:phy fix driver reference count error when attach and
 detach phy device
Date: Mon, 23 Jan 2017 17:33:41 +0800
Message-ID: <83f87925-5456-1896-e8ff-4d9f724158e4@huawei.com>
References: <1480501378-10172-1-git-send-email-maowenan@huawei.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0232613@AcuExch.aculab.com>
 <0cef0798-7b0d-734d-17a3-bebffe6206c7@huawei.com>
 <7902ba31-de5d-27cf-f631-4a88a78b246f@huawei.com>
 <c4fce3bf-4105-c7f2-fc67-be4316a2004a@gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F201524E04@szxeml504-mbs.china.huawei.com>
 <70502429-5edf-924f-6e48-89340620ae6f@gmail.com>
 <cbd390e3-666b-dcc3-2ff3-18fa75549167@huawei.com>
 <9086cf5e-18c4-0e17-4f0e-6a630cf1c7d7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Dingtianhong <dingtianhong@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:54038 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAWJfb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 04:35:31 -0500
In-Reply-To: <9086cf5e-18c4-0e17-4f0e-6a630cf1c7d7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/1/6 12:48, Florian Fainelli wrote:
> Le 01/05/17 à 19:39, maowenan a écrit :
>>
>>
>> On 2017/1/6 11:21, Florian Fainelli wrote:
>>> +Andrew,
>>>
>>> Le 01/05/17 à 18:29, maowenan a écrit :
>>>>>> @Florian Fainelli, what's your comments about this patch?
>>>>>
>>>>> I am trying to reproduce what you are seeing, but at first glance is looks like an
>>>>> appropriate solution to me. Do you mind giving me a couple more days?
>>>>>
>>>>> Thanks!
>>>>> --
>>>>> Florian
>>>>
>>>> Hi Florian, 
>>>>   Do you have any update about this patch?
>>>
>>> Your patch is not complete, there are now MDIO device (which PHY devices
>>> are a superset of) that would also need a similar fix.
>>>
>> ok, is there any patch to fix MDIO yet?  if not, i will verify it and give a fix patch?
>>
> 
> No, there is not a patch yet, your approach looks okay, but need to be
> made general and cover MDIO devices as well.
> 
> Thank you!
> 

Hi Florian,
Sorry I can't get you. There has already existed codes which are not originally written by me to cover MDIO device in phy_attach_direct and phy_detach in my patch .
Please help check, thank you.
phy_attach_direct:
struct device *d = &phydev->mdio.dev;
...
get_device(d);
...

phy_detach:
 	put_device(&phydev->mdio.dev);       /*--MDIO device--*/
+	module_put(phydev->mdio.dev.driver->owner);
 	module_put(bus->owner);
