From: Chen Gang F T <chen.gang.flying.transformer@gmail.com>
Subject: Re: [PATCH] drivers/net/wireless/iwlegacy: use strlcpy instead of
 strncpy
Date: Sun, 20 Jan 2013 18:45:17 +0800
Message-ID: <50FBCABD.6070205@gmail.com>
References: <50EA5246.8060206@asianux.com> <50FBB977.7080805@asianux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050507030308040906040103"
Cc: sgruszka@redhat.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:61359 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3ATKoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 05:44:37 -0500
In-Reply-To: <50FBB977.7080805@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050507030308040906040103
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit

  oh, sorry, it is my fault.

  according to fill_write_buffer in fs/sysfs/file.c,
    we can assume that 'const char *buf' must be '\0' based string.

  please skip original reply.


gchen.

于 2013年01月20日 17:31, Chen Gang 写道:
> Hello all:
> 
>   sorry, after checking the details:
>     I think this patch is incorrect.
>       we can not assume that the parameter "char *buf" is terminated by '\0'
>       so we should only use strlcpy instead of strncpy, without touching 'min(...'
> 
>   since it is already integrated into main branch (at least, in next-20130118).
>     I should send additional patch to fix it.
> 
>   please help to check, thanks.
> 
> 
> gchen.
> 
> 
> 于 2013年01月07日 12:42, Chen Gang 写道:
>>
>>   The fields must be null-terminated, or simple_strtoul will cause issue.
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>  drivers/net/wireless/iwlegacy/3945-mac.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
>> index d604b40..3726cd6 100644
>> --- a/drivers/net/wireless/iwlegacy/3945-mac.c
>> +++ b/drivers/net/wireless/iwlegacy/3945-mac.c
>> @@ -3273,7 +3273,7 @@ il3945_store_measurement(struct device *d, struct device_attribute *attr,
>>  
>>  	if (count) {
>>  		char *p = buffer;
>> -		strncpy(buffer, buf, min(sizeof(buffer), count));
>> +		strlcpy(buffer, buf, sizeof(buffer));
>>  		channel = simple_strtoul(p, NULL, 0);
>>  		if (channel)
>>  			params.channel = channel;
>>
> 
> 


-- 
Chen Gang

Flying Transformer

--------------050507030308040906040103
Content-Type: text/x-vcard; charset=utf-8;
 name="chen_gang_flying_transformer.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chen_gang_flying_transformer.vcf"

YmVnaW46dmNhcmQNCmZuOkNoZW4gR2FuZw0Kbjo7Q2hlbiBHYW5nDQp2ZXJzaW9uOjIuMQ0K
ZW5kOnZjYXJkDQoNCg==
--------------050507030308040906040103--
