From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Fri, 25 Oct 2013 06:05:40 -0400
Message-ID: <CAGCdqXG6pOdaHNDsKnMGWKRs8Me7F8oyWVcgmtGP8ng2XRGfcQ@mail.gmail.com>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
	<20131024140253.GF15744@order.stressinduktion.org>
	<20131024165931.GA1475@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:37448 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab3JYKFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 06:05:41 -0400
Received: by mail-wg0-f49.google.com with SMTP id x12so3642891wgg.16
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 03:05:40 -0700 (PDT)
In-Reply-To: <20131024165931.GA1475@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 12:59 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 24, 2013 at 04:02:53PM CEST, hannes@stressinduktion.org wrote:
>>On Thu, Oct 24, 2013 at 03:45:55PM +0200, Jiri Pirko wrote:
>>> This is needed in order to implement userspace address configuration,
>>> namely ip6-privacy (rfc4941) in NetworkManager.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>  net/ipv6/addrconf.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>> index cd3fb30..962c7c9 100644
>>> --- a/net/ipv6/addrconf.c
>>> +++ b/net/ipv6/addrconf.c
>>> @@ -3715,7 +3715,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
>>>              return -ENODEV;
>>>
>>>      /* We ignore other flags so far. */
>>> -    ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
>>> +    ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS |
>>> +                                  IFA_F_TEMPORARY);
>>>
>>>      ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
>>>      if (ifa == NULL) {
>>
>>Hm, the kernel will pick up IFA_F_TEMPORARY marked addresses and do ipv6 address
>>regeneration (depending on lifetimes). Is this intended?
>
> I think that that behaviour is valid. It is in compliance with valid lft and
> preferred lft behaviour.
>

Actually, I don't think it would do the regeneration since ifpub
pointer is not set.

I appears that the temp address management would have to be done in
userspace.

-vlad


>>
>>Btw. I am very interested in this topic as there is currently work in the IETF
>>to move away from eui-48 generation of addresses:
>>
>>https://datatracker.ietf.org/doc/draft-ietf-6man-stable-privacy-addresses/
>>
>>This needs to be done in userspace as we depend on a secret generated at
>>system install time.
>>
>>Greetings,
>>
>>  Hannes
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
