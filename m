From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.26 5/10][VLAN]: Add a net argument to proc init
 and cleanup calls.
Date: Tue, 15 Apr 2008 17:05:30 +0400
Message-ID: <4804A81A.5070503@openvz.org>
References: <4804989F.1060503@openvz.org> <48049B01.80403@openvz.org> <48049EE7.1090407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46544 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636AbYDOMbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:31:21 -0400
In-Reply-To: <48049EE7.1090407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +++ b/net/8021q/vlan.c
>> @@ -642,8 +642,14 @@ static int vlan_init_net(struct net *net)
>>  	if (err < 0)
>>  		goto err_assign;
>>  
>> +	err = vlan_proc_init(net);
>> +	if (err < 0)
>> +		goto err_proc;
>> +
>>  	return 0;
>>  
>> +err_proc:
>> +	/* nothing */
> 
> What is going to clean up net_generic_assign above?

This is not required. Net will be just destroyed after this
function returns.

>> @@ -693,8 +696,6 @@ static int __init vlan_proto_init(void)
>>  err3:
>>  	unregister_netdevice_notifier(&vlan_notifier_block);
>>  err2:
>> -	vlan_proc_cleanup();
>> -err1:
>>  	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
>>  err0:
>>  	return err;
> 
> This could be done nicer, not leaving holes in the numbering.

Well, yes. Bu this patch is large enough without it. Can I make
this in a separate patch?
