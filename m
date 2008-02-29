From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 03/15] [SUNRPC]: Use proc_create() to setup ->proc_fops
 first
Date: Fri, 29 Feb 2008 13:26:43 +0800
Message-ID: <47C79793.8060108@cn.fujitsu.com>
References: <47C6932C.90907@cn.fujitsu.com> <20080228.140222.07061140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@sw.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52959 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbYB2F3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 00:29:13 -0500
In-Reply-To: <20080228.140222.07061140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-2-29 6:02:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Thu, 28 Feb 2008 18:55:40 +0800
> 
>> Use proc_create() to make sure that ->proc_fops be setup before gluing
>> PDE to main tree.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Applied.
> 
>> @@ -229,9 +229,8 @@ do_register(const char *name, void *data, const struct file_operations *fops)
>>  	rpc_proc_init();
>>  	dprintk("RPC:       registering /proc/net/rpc/%s\n", name);
>>  
>> -	ent = create_proc_entry(name, 0, proc_net_rpc);
>> +	ent = proc_create(name, 0, proc_net_rpc, fops);
>>  	if (ent) {
>> -		ent->proc_fops = fops;
>>  		ent->data = data;
>>  	}
>>  	return ent;
> 
> For this case it appears that ent->data has the same kind of
> visibility problem that ent->proc_fops does.
> 

Thanks Dave, I will check whether ->data also has the visibility problem.

