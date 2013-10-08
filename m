From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 8 Oct 2013 16:52:17 +0200
Message-ID: <CAKv+Gu8D_7d=u1PGWuxoLEETHe8uJMby3K98uQWQn7tk=t_t_w@mail.gmail.com>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	<1381233152.13359.10.camel@jlt4.sipsolutions.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B737B@saturn3.aculab.com>
	<23D74823-0DE3-4A87-9E89-310F437A328D@linaro.org>
	<1381239908.13359.12.camel@jlt4.sipsolutions.net>
	<1381239951.13359.13.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	"<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>" <patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1381239951.13359.13.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8 October 2013 15:45, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Tue, 2013-10-08 at 15:45 +0200, Johannes Berg wrote:
>> On Tue, 2013-10-08 at 15:41 +0200, Ard Biesheuvel wrote:
>>
>> > Actually, as the size is always the same, it should be feasible to
>> > alloc a couple of request structs at init time. would one for rx and
>> > one for tx be sufficient? or is this code more reentrant than that?
>>
>> TX can run concurrently on multiple (four) queues using the same key.
>
> And maybe even more with injection ... I wouldn't go there.
>

OK, clear.

If you think this patch has any merit at all, I am happy to modify it
so that it kmalloc()s the request struct with GFP_ATOMIC at every
invocation.
However, personally I don't think this should be necessary and in fact
my patch removes a stack allocation of u8[48] (from
ieee80211_crypto_ccmp_decrypt() and from ccmp_encrypt_skb() in wpa.c)
so it does even out a bit.

regards,
Ard.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
