From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 1/14][NETNS]: Introduce the net-subsys id generator.
Date: Fri, 11 Apr 2008 11:56:34 +0400
Message-ID: <47FF19B2.3020002@openvz.org>
References: <47FE2AD4.9080609@openvz.org> <47FE2BB5.4070708@openvz.org> <47FE7E1C.50403@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Menage <menage@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33183 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754393AbYDKHcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 03:32:47 -0400
In-Reply-To: <47FE7E1C.50403@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +int register_pernet_gen_device(int *id, struct pernet_operations *ops)
>> +{
>> +	int error;
>> +	mutex_lock(&net_mutex);
>> +again:
>> +	error = ida_get_new_above(&net_generic_ids, 1, id);
>> +	if (error) {
>> +		if (error == -EAGAIN) {
>> +			ida_pre_get(&net_generic_ids, GFP_KERNEL);
>> +			goto again;
>> +		}
> 
> 		goto out;
> 
>> +	}
>> +	error = register_pernet_operations(first_device, ops);
>> +	if (error)
>> +		ida_remove(&net_generic_ids, *id);
>> +	else if (first_device == &pernet_list)
>> +		first_device = &ops->list;
> 
> out:

Oops! Thank, will fix.
