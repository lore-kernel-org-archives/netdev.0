From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Thu, 12 Jul 2007 17:58:41 +0400
Message-ID: <46963391.1080609@openvz.org>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <46961F21.7030409@trash.net> <4696293A.4030108@openvz.org> <46962AC5.2030005@trash.net> <46962E6A.5020906@openvz.org> <4696305B.5070809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:32025 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932102AbXGLN65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 09:58:57 -0400
In-Reply-To: <4696305B.5070809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> Patrick McHardy wrote:
>>
>>> No, to get unique names the sequence has to be:
>>>
>>> dev_alloc_name
>>> register_netdevice
>>> dev_alloc_name
>>> register_netdevice
>>>
>>> But you have:
>>>
>>> dev_alloc_name
>>> dev_alloc_name (<- might allocate same name as first call)
>>> register_netdevice
>>> register_netdevice
>>
>> Oops :) You're right. That's the problem. I was carried away by
>> testing the "peer" options and checking for names rather than
>> "veth%d" to work...
>>
>> By the way, that will create some problems. You see, your patches
>> imply that the register_netdevice() will be called at the very end
>> of the ->newlink callback. Otherwise, the error path of any code
>> following the registering will have to call unregister_netdevice()
>> which will BUG() in free_netdev() in rtnl_newlink() - the device
>> state will be neither UNINITIALIZED nor UNREGISTERED :(
> 
> 
> Thats true. I think you could do:
> 
> - use name of the supplied device for the second device
> - register second device
> - allocate new name for first device
> - register first device
> 

Not 100% like this (since the first name is expected to be associated
with the device with the first address), but reallocating the name for
the first device sounds like a good idea.

David, which way would be more preferable - to fix booth issues pointed
by Patric and send the v.4 patch, or to wait for this patch to be committed
and then send two incremental fixes?

Pavel
