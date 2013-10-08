From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 8 Oct 2013 15:41:33 +0200
Message-ID: <23D74823-0DE3-4A87-9E89-310F437A328D@linaro.org>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org> <1381233152.13359.10.camel@jlt4.sipsolutions.net> <AE90C24D6B3A694183C094C60CF0A2F6026B737B@saturn3.aculab.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>" <patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B737B-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 8 okt. 2013, at 15:01, "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> wrote:

>> Hmm, thanks I guess. I'll need to review this in more detail, but I have
>> a question first:
>> 
>>> +    /* allocate the variable sized aead_request on the stack */
>>> +    int l = DIV_ROUND_UP(crypto_aead_reqsize(tfm),
>>> +                 sizeof(struct aead_request));
>>> +    struct aead_request req[1 + l];
>> 
>> This looks a bit odd, why round up first and then add one? Why even
>> bother using a struct array rather than some local struct like
> 
> Is it even a good idea to be allocating variable sized items
> on the kernel stack?
> 
> There has to be enough stack available for the maximum number
> of entries - so there is little point in dynamically sizing it.

Actually, as the size is always the same, it should be feasible to alloc a couple of request structs at init time. would one for rx and one for tx be sufficient? or is this code more reentrant than that?

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
