From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 2.6.25] net: removes unnecessary dependencies for net_namespace.h
Date: Mon, 03 Dec 2007 15:09:40 +0300
Message-ID: <4753F204.2010900@sw.ru>
References: <20071203091200.GA20442@iris.sw.ru> <m1odd80z72.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010409060009020000090507"
Cc: "Denis V. Lunev" <den@openvz.org>, herbert@gondor.apana.org.au,
	devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net,
	xemul@openvz.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:58307 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751384AbXLCMIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 07:08:50 -0500
In-Reply-To: <m1odd80z72.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010409060009020000090507
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

you right, how about this?

Eric W. Biederman wrote:
> "Denis V. Lunev" <den@openvz.org> writes:
> 
>> This patch removes some unneeded includes for net_namespace.h to speed up
>> compilation.
>>
>> Signed-off-by: Denis V. Lunev <den@openvz.org>
>>
>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>> index f285de6..28b7f25 100644
>> --- a/include/net/pkt_cls.h
>> +++ b/include/net/pkt_cls.h
>> @@ -2,7 +2,6 @@
>>  #define __NET_PKT_CLS_H
>>  
>>  #include <linux/pkt_cls.h>
>> -#include <net/net_namespace.h>
>>  #include <net/sch_generic.h>
>>  #include <net/act_api.h>
> 
> What of tcf_match_indev?  I guess linux/netdevice.h brings
> it in for us but still.
> 
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 43e3cd9..a04e361 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -57,7 +57,6 @@
>>  #include <asm/atomic.h>
>>  #include <net/dst.h>
>>  #include <net/checksum.h>
>> -#include <net/net_namespace.h>
>>  
>>  /*
>>   * This structure really needs to be cleaned up.
>> @@ -95,6 +94,7 @@ typedef struct {
>>  
>>  struct sock;
>>  struct proto;
>> +struct net;
>>  
>>  /**
>>   *	struct sock_common - minimal network layer representation of sockets
> 
> This hunk definitely looks sane.
> 
> Eric
> 
> 


--------------010409060009020000090507
Content-Type: text/plain;
 name="1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="1.diff"

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f285de6..2eaf204 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -2,7 +2,6 @@
 #define __NET_PKT_CLS_H
 
 #include <linux/pkt_cls.h>
-#include <net/net_namespace.h>
 #include <net/sch_generic.h>
 #include <net/act_api.h>
 
@@ -336,6 +335,8 @@ static inline int tcf_valid_offset(const struct sk_buff *skb,
 }
 
 #ifdef CONFIG_NET_CLS_IND
+#include <net/net_namespace.h>
+
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
 {
diff --git a/include/net/sock.h b/include/net/sock.h
index 43e3cd9..a04e361 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -57,7 +57,6 @@
 #include <asm/atomic.h>
 #include <net/dst.h>
 #include <net/checksum.h>
-#include <net/net_namespace.h>
 
 /*
  * This structure really needs to be cleaned up.
@@ -95,6 +94,7 @@ typedef struct {
 
 struct sock;
 struct proto;
+struct net;
 
 /**
  *	struct sock_common - minimal network layer representation of sockets

--------------010409060009020000090507--
