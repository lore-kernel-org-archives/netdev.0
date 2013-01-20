From: Chen Gang F T <chen.gang.flying.transformer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [suggestion]  drivers/net/wireless/iwlegacy: the parameter 'const
 char *buf' may be not '\0' base string for DINFO
Date: Sun, 20 Jan 2013 18:44:34 +0800
Message-ID: <50FBCA92.7000207@gmail.com>
References: <50FBC180.2090003@asianux.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060306020409070507080108"
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50FBC180.2090003-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060306020409070507080108
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 8bit

  oh, sorry, it is my fault.

  according to fill_write_buffer in fs/sysfs/file.c,
    we can assume that 'const char *buf' must be '\0' based string.

  please skip this suggestion.


gchen.

于 2013年01月20日 18:05, Chen Gang 写道:
> Hello Stanislaw, John
> 
>   we can not assume that the parameter 'const char *buf' is '\0' base string.
>   and DINOF uses '%s' for buf (in line 3288..3289)
>   so it will cause issue.
> 
>   I am not quite familiar with the detail features.
>   so I send mail as a suggestion.
>   please help checking, if this suggestion is valid, please help fixing, thanks.
> 
>   Regards
> 
> gchen.
> 
> 3260 static ssize_t
> 3261 il3945_store_measurement(struct device *d, struct device_attribute *attr,
> 3262                          const char *buf, size_t count)
> 3263 {
> 3264         struct il_priv *il = dev_get_drvdata(d);
> 3265         struct ieee80211_measurement_params params = {
> 3266                 .channel = le16_to_cpu(il->active.channel),
> 3267                 .start_time = cpu_to_le64(il->_3945.last_tsf),
> 3268                 .duration = cpu_to_le16(1),
> 3269         };
> 3270         u8 type = IL_MEASURE_BASIC;
> 3271         u8 buffer[32];
> 3272         u8 channel;
> 3273 
> 3274         if (count) {
> 3275                 char *p = buffer;
> 3276                 strlcpy(buffer, buf, min(sizeof(buffer), count));
> 3277                 channel = simple_strtoul(p, NULL, 0);
> 3278                 if (channel)
> 3279                         params.channel = channel;
> 3280 
> 3281                 p = buffer;
> 3282                 while (*p && *p != ' ')
> 3283                         p++;
> 3284                 if (*p)
> 3285                         type = simple_strtoul(p + 1, NULL, 0);
> 3286         }
> 3287 
> 3288         D_INFO("Invoking measurement of type %d on " "channel %d (for '%s')\n",
> 3289                type, params.channel, buf);
> 3290         il3945_get_measurement(il, &params, type);
> 3291 
> 3292         return count;
> 3293 }
> 3294 
> 
> 
> 
> 


-- 
Chen Gang

Flying Transformer

--------------060306020409070507080108
Content-Type: text/x-vcard; charset=utf-8;
 name="chen_gang_flying_transformer.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chen_gang_flying_transformer.vcf"

YmVnaW46dmNhcmQNCmZuOkNoZW4gR2FuZw0Kbjo7Q2hlbiBHYW5nDQp2ZXJzaW9uOjIuMQ0K
ZW5kOnZjYXJkDQoNCg==
--------------060306020409070507080108--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
