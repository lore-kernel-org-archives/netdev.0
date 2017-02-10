From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: net: hix5hd2_gmac uninitialized net_device
Date: Fri, 10 Feb 2017 18:21:35 +0800
Message-ID: <589D942F.7070700@hisilicon.com>
References: <20170210074118.vchxsn7fag6tlsmg@tha-monstah.mydomain>
 <20170210074544.eoabpjf522pmwoui@tha-monstah.mydomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>
To: Marty Plummer <netz.kernel@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:36928 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752357AbdBJKXN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 05:23:13 -0500
In-Reply-To: <20170210074544.eoabpjf522pmwoui@tha-monstah.mydomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/2/10 15:45, Marty Plummer wrote:
> On Fri, Feb 10, 2017 at 01:41:18AM -0600, Marty Plummer wrote:
>> Greetings.
>>
>> I think I may have found a bug with the hix5hd2_gmac driver; unless I'm
>> missing something, it appears that somehow the net_device struct is not
>> being initialized properly in the hix5hd2_dev_probe function.
>>
>> Having set up my devicetree properly (I hope, still new to this), I first
>> recieved an error when inserting the module:
>> "(unnamed net_device) (uninitialized): No irq resource"
>> while I very clearly have the interrupts property defined within this node.
>>
I think the error "No irq resource" happened for some other reason, has no relation with
the info "(unnamed net_device) (uninitialized):".
You can add more debug info to find bug.

>> Removing the phy-handle node for testing purposes, I get a similar message:
>> "(unnamed net_device) (uninitialized): not find phy-handle"
>>
>> So, it seams to my (admittedly inexperienced) mind that the ndev pointer is
>> not being initialized properly, or that the error checking at line 1111
>> is not functioning properly either, for it to have gotten so far along
>> into the function, only to fail at the attempt to access the ndev pointer.
>>
Yes, I agree with you that the ndev has not been initialized completely,
because the function "register_netdev" has not been called yet.
It's better to use the "dev_err" to replace the "netdev_err".

>> If you require more information from me, please let me know.
>>
>> Marty
> 
> Sorry, forgot the subject. Still getting the hang of mutt.
> 
> 

    Regards,
    Dongpo

.
