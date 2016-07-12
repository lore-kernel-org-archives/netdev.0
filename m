From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Tue, 12 Jul 2016 08:47:58 +0200
Message-ID: <20160712064758.GB1884@nanopsycho.orion>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
 <20160711165412.0ba05675@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33731 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbcGLGsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 02:48:02 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so1092017wme.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 23:48:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160711165412.0ba05675@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 11, 2016 at 10:54:12PM CEST, rostedt@goodmis.org wrote:
>On Mon, 11 Jul 2016 15:18:47 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> diff --git a/include/net/devlink.h b/include/net/devlink.h
>> index c99ffe8..865ade6 100644
>> --- a/include/net/devlink.h
>> +++ b/include/net/devlink.h
>> @@ -115,6 +115,8 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size);
>>  int devlink_register(struct devlink *devlink, struct device *dev);
>>  void devlink_unregister(struct devlink *devlink);
>>  void devlink_free(struct devlink *devlink);
>> +void devlink_trace_hwmsg(const struct devlink *devlink, bool incoming,
>> +			 unsigned long type, const u8 *buf, size_t len);
>>  int devlink_port_register(struct devlink *devlink,
>>  			  struct devlink_port *devlink_port,
>>  			  unsigned int port_index);
>> @@ -154,6 +156,12 @@ static inline void devlink_free(struct devlink *devlink)
>>  	kfree(devlink);
>>  }
>>  
>> +static inline void devlink_trace_hwmsg(const struct devlink *devlink,
>> +				       bool incoming, unsigned long type,
>> +				       const u8 *buf, size_t len);
>> +{
>> +}
>> +
>
>I'm assuming the !CONFIG_NET_DEVLINK was never tested, because the
>above probably wont build, and if it did, it would be wrong.

Will fix.
