From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 5/10][VLAN]: Add a net argument to proc init
 and cleanup calls.
Date: Tue, 15 Apr 2008 14:31:59 +0200
Message-ID: <4804A03F.3010206@trash.net>
References: <4804989F.1060503@openvz.org> <48049B01.80403@openvz.org> <48049EE7.1090407@trash.net> <4804A81A.5070503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35790 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758049AbYDOMcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:32:05 -0400
In-Reply-To: <4804A81A.5070503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
>>> +++ b/net/8021q/vlan.c
>>> @@ -642,8 +642,14 @@ static int vlan_init_net(struct net *net)
>>>  	if (err < 0)
>>>  		goto err_assign;
>>>  
>>> +	err = vlan_proc_init(net);
>>> +	if (err < 0)
>>> +		goto err_proc;
>>> +
>>>  	return 0;
>>>  
>>> +err_proc:
>>> +	/* nothing */
>> What is going to clean up net_generic_assign above?
> 
> This is not required. Net will be just destroyed after this
> function returns.

Thanks for the explanation, I wasn't sure about that.

> 
>>> @@ -693,8 +696,6 @@ static int __init vlan_proto_init(void)
>>>  err3:
>>>  	unregister_netdevice_notifier(&vlan_notifier_block);
>>>  err2:
>>> -	vlan_proc_cleanup();
>>> -err1:
>>>  	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
>>>  err0:
>>>  	return err;
>> This could be done nicer, not leaving holes in the numbering.
> 
> Well, yes. Bu this patch is large enough without it. Can I make
> this in a separate patch?

Of course, thanks.
