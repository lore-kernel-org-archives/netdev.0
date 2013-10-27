From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Sun, 27 Oct 2013 14:29:41 +0100
Message-ID: <20131027132941.GA1443@minipsycho.orion>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
 <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, Stephen Hemminger <stephen@networkplumber.org>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:62251 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab3J0N3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 09:29:44 -0400
Received: by mail-ea0-f180.google.com with SMTP id l9so1303660eaj.39
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 06:29:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 26, 2013 at 01:05:34AM CEST, vyasevich@gmail.com wrote:
>On Thu, Oct 24, 2013 at 9:45 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This is needed in order to implement userspace address configuration,
>> namely ip6-privacy (rfc4941) in NetworkManager.
>>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/ipv6/addrconf.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index cd3fb30..962c7c9 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -3715,7 +3715,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
>>                 return -ENODEV;
>>
>>         /* We ignore other flags so far. */
>> -       ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
>> +       ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS |
>> +                                     IFA_F_TEMPORARY);
>>
>>         ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
>>         if (ifa == NULL) {
>> --
>> 1.8.3.1
>>
>
>Jiri
>
>So, is the idea behind this is that all of temp address management
>would be done in user space?  If so, then you
>may have to verify that no-one sets the lifetime values on the prefix
>in your other patch.   I am still trying to figure out
>why this would be needed.

The idea is to provide possibility to do address configuration not in
kernel but rather in userspace (as it is done for example in NetworkManager)

Maybe I'm missing something, but why is it problem to have the
possibility to set lifetime even for temporary prefix?

>
>Thanks
>-vlad
