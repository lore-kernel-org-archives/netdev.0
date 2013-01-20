From: Chen Gang F T <chen.gang.flying.transformer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers/net/wireless/iwlegacy: adding check length for
 parameter buf
Date: Sun, 20 Jan 2013 18:43:48 +0800
Message-ID: <50FBCA64.20505@gmail.com>
References: <50FBBEB2.2000306@asianux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030204050601060100040608"
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50FBBEB2.2000306-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030204050601060100040608
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit

  oh, sorry, it is my fault.

  according to fill_write_buffer in fs/sysfs/file.c,
    we can assume that 'const char *buf' must be '\0' based string.

  please skip this patch.


gchen.


于 2013年01月20日 17:53, Chen Gang 写道:
> 
>   the parameter 'const char *buf' may be not '\0' based string.
>   so need check the length before use it.
> 
> additinal info:
>   originally, it had the relative checking.
>   but it was deleted when fix another issues (using strlcpy instead of
> strncpy)
>   and now, we need restore the checking (but still keep strlcpy)
> 
> Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/net/wireless/iwlegacy/3945-mac.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c
> b/drivers/net/wireless/iwlegacy/3945-mac.c
> index 050ce7c..71cdbac 100644
> --- a/drivers/net/wireless/iwlegacy/3945-mac.c
> +++ b/drivers/net/wireless/iwlegacy/3945-mac.c
> @@ -3273,7 +3273,7 @@ il3945_store_measurement(struct device *d, struct
> device_attribute *attr,
> 
>  	if (count) {
>  		char *p = buffer;
> -		strlcpy(buffer, buf, sizeof(buffer));
> +		strlcpy(buffer, buf, min(sizeof(buffer), count));
>  		channel = simple_strtoul(p, NULL, 0);
>  		if (channel)
>  			params.channel = channel;
> 


-- 
Chen Gang

Flying Transformer

--------------030204050601060100040608
Content-Type: text/x-vcard; charset=utf-8;
 name="chen_gang_flying_transformer.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chen_gang_flying_transformer.vcf"

YmVnaW46dmNhcmQNCmZuOkNoZW4gR2FuZw0Kbjo7Q2hlbiBHYW5nDQp2ZXJzaW9uOjIuMQ0K
ZW5kOnZjYXJkDQoNCg==
--------------030204050601060100040608--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
