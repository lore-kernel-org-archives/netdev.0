From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Thu, 12 Jul 2007 15:44:59 +0200
Message-ID: <4696305B.5070809@trash.net>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <46961F21.7030409@trash.net> <4696293A.4030108@openvz.org> <46962AC5.2030005@trash.net> <46962E6A.5020906@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47489 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761016AbXGLNpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 09:45:22 -0400
In-Reply-To: <46962E6A.5020906@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Patrick McHardy wrote:
> 
>>No, to get unique names the sequence has to be:
>>
>>dev_alloc_name
>>register_netdevice
>>dev_alloc_name
>>register_netdevice
>>
>>But you have:
>>
>>dev_alloc_name
>>dev_alloc_name (<- might allocate same name as first call)
>>register_netdevice
>>register_netdevice
> 
> 
> Oops :) You're right. That's the problem. I was carried away by
> testing the "peer" options and checking for names rather than
> "veth%d" to work...
> 
> By the way, that will create some problems. You see, your patches
> imply that the register_netdevice() will be called at the very end
> of the ->newlink callback. Otherwise, the error path of any code
> following the registering will have to call unregister_netdevice()
> which will BUG() in free_netdev() in rtnl_newlink() - the device
> state will be neither UNINITIALIZED nor UNREGISTERED :(


Thats true. I think you could do:

- use name of the supplied device for the second device
- register second device
- allocate new name for first device
- register first device
