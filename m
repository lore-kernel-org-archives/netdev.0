From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] ipv4: fix nexthop attlen check in fib_nh_match
Date: Mon, 13 Oct 2014 16:34:42 +0200
Message-ID: <20141013143442.GB2224@nanopsycho.orion>
References: <1413194063-10354-1-git-send-email-jiri@resnulli.us>
 <1413202966.9362.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:52570 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbaJMOeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 10:34:44 -0400
Received: by mail-wg0-f43.google.com with SMTP id m15so8630281wgh.2
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 07:34:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1413202966.9362.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 13, 2014 at 02:22:46PM CEST, eric.dumazet@gmail.com wrote:
>On Mon, 2014-10-13 at 11:54 +0200, Jiri Pirko wrote:
>> fib_nh_match does not match nexthops correctly. Example:
>> 
>> This command is not successful and route is removed. After this patch
>> applied, the route is correctly matched and result is:
>> RTNETLINK answers: No such process
>> 
>> Please consider this for stable trees as well.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/ipv4/fib_semantics.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
>> index 5b6efb3..f99f41b 100644
>> --- a/net/ipv4/fib_semantics.c
>> +++ b/net/ipv4/fib_semantics.c
>> @@ -537,7 +537,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
>>  			return 1;
>>  
>>  		attrlen = rtnh_attrlen(rtnh);
>> -		if (attrlen < 0) {
>> +		if (attrlen > 0) {
>>  			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
>>  
>>  			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
>
>Fixes: 4e902c57417c4 ("[IPv4]: FIB configuration using struct fib_config")
>
>Good catch, thanks !
>
>Acked-by: Eric Dumazet <edumazet@google.com>


Thanks Eric. I reposted with your ack, fixes line and missing example.
