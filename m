From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 08/12] netlink: Export genl_lock() API for use by modules
Date: Thu, 18 Mar 2010 17:46:29 +0000
Message-ID: <4BA266F5.7020101@katalix.com>
References: <20100318102127.14576.98388.stgit@bert.katalix.com>	<20100318102209.14576.61503.stgit@bert.katalix.com> <20100318090037.69bcd073@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:46832 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156Ab0CRRqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 13:46:44 -0400
In-Reply-To: <20100318090037.69bcd073@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 18 Mar 2010 10:22:10 +0000
> James Chapman <jchapman@katalix.com> wrote:
> 
>> This lets kernel modules which use genl netlink APIs serialize netlink
>> processing.
>>
>> Signed-off-by: James Chapman <jchapman@katalix.com>
>> ---
>>  include/linux/genetlink.h |    8 ++++++++
>>  net/netlink/genetlink.c   |    6 ++++--
>>  2 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
>> index b834ef6..61549b2 100644
>> --- a/include/linux/genetlink.h
>> +++ b/include/linux/genetlink.h
>> @@ -80,4 +80,12 @@ enum {
>>  
>>  #define CTRL_ATTR_MCAST_GRP_MAX (__CTRL_ATTR_MCAST_GRP_MAX - 1)
>>  
>> +#ifdef __KERNEL__
>> +
>> +/* All generic netlink requests are serialized by a global lock.  */
>> +extern void genl_lock(void);
>> +extern void genl_unlock(void);
>> +
>> +#endif /* __KERNEL__ */
>> +
>>  #endif	/* __LINUX_GENERIC_NETLINK_H */
>> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
>> index a4b6e14..a28fda7 100644
>> --- a/net/netlink/genetlink.c
>> +++ b/net/netlink/genetlink.c
>> @@ -20,15 +20,17 @@
>>  
>>  static DEFINE_MUTEX(genl_mutex); /* serialization of message processing */
>>  
>> -static inline void genl_lock(void)
>> +void genl_lock(void)
>>  {
>>  	mutex_lock(&genl_mutex);
>>  }
>> +EXPORT_SYMBOL(genl_lock);
>>  
>> -static inline void genl_unlock(void)
>> +void genl_unlock(void)
>>  {
>>  	mutex_unlock(&genl_mutex);
>>  }
>> +EXPORT_SYMBOL(genl_unlock);
> 
> EXPORT_SYMBOL_GPL() for this?

I chose EXPORT_SYMBOL because other exported symbols in that module
aren't GPL-only. I don't mind which is used. Any preference, Thomas?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

