From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] switchdev: bring back switchdev_obj and use it
 as a generic object param
Date: Thu, 1 Oct 2015 08:24:50 +0200
Message-ID: <20151001062449.GA2153@nanopsycho.orion>
References: <1443628815-25095-1-git-send-email-jiri@resnulli.us>
 <20150930180040.GC21695@ketchup.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, andrew@lunn.ch, Jiri Pirko <jiri@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35696 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbbJAGYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 02:24:54 -0400
Received: by wicge5 with SMTP id ge5so13622675wic.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 23:24:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150930180040.GC21695@ketchup.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 30, 2015 at 08:00:40PM CEST, vivien.didelot@savoirfairelinux.com wrote:

<snip>

>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>> index e11425e..a79a7f0 100644
>> --- a/include/net/switchdev.h
>> +++ b/include/net/switchdev.h
>> @@ -64,15 +64,23 @@ enum switchdev_obj_id {
>>  	SWITCHDEV_OBJ_PORT_FDB,
>>  };
>>  
>> +struct switchdev_obj {
>> +};
>> +
>>  /* SWITCHDEV_OBJ_PORT_VLAN */
>>  struct switchdev_obj_vlan {
>> +	struct switchdev_obj obj;
>>  	u16 flags;
>>  	u16 vid_begin;
>>  	u16 vid_end;
>>  };
>>  
>> +#define SWITCHDEV_OBJ_VLAN(obj) \
>> +	container_of(obj, struct switchdev_obj_vlan, obj)
>> +
>>  /* SWITCHDEV_OBJ_IPV4_FIB */
>>  struct switchdev_obj_ipv4_fib {
>> +	struct switchdev_obj obj;
>>  	u32 dst;
>>  	int dst_len;
>>  	struct fib_info *fi;
>> @@ -82,18 +90,27 @@ struct switchdev_obj_ipv4_fib {
>>  	u32 tb_id;
>>  };
>>  
>> +#define SWITCHDEV_OBJ_IPV4_FIB(obj) \
>> +	container_of(obj, struct switchdev_obj_ipv4_fib, obj)
>
>Isn't there a collision to have a SWITCHDEV_OBJ_IPV4_FIB enum and a
>SWITCHDEV_OBJ_IPV4_FIB macro?
>
>Maybe switchdev will support not only port-objects, but also switch chip
>objects, so would it be good to make the distinction between them? e.g.:
>
> * struct switchdev_obj_port_vlan
> * SWITCHDEV_OBJ_ID_PORT_VLAN
> * SWITCHDEV_OBJ_PORT_VLAN(obj)
> * ...
>
>What do you think?

Sounds good. Will make adjustments.

Thanks
