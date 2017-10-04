From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/3] bridge: add new BR_NEIGH_SUPPRESS port
 flag to suppress arp and nd flood
Date: Tue, 3 Oct 2017 21:47:19 -0700
Message-ID: <CAJieiUhLiTbt-+SWJ2Yq6WxYR+x=hLM_ONyqt+kCDBWbKCTU+w@mail.gmail.com>
References: <1507054876-16746-1-git-send-email-roopa@cumulusnetworks.com>
 <1507054876-16746-2-git-send-email-roopa@cumulusnetworks.com> <20171003112948.44d9cc56@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:48498 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdJDErU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:47:20 -0400
Received: by mail-vk0-f51.google.com with SMTP id g69so5706135vke.5
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 21:47:20 -0700 (PDT)
In-Reply-To: <20171003112948.44d9cc56@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 11:29 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue,  3 Oct 2017 11:21:14 -0700
> Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
>> index 48fb174..7a50dc5 100644
>> --- a/net/bridge/br_forward.c
>> +++ b/net/bridge/br_forward.c
>> @@ -204,7 +204,8 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
>>               /* Do not flood to ports that enable proxy ARP */
>>               if (p->flags & BR_PROXYARP)
>>                       continue;
>> -             if ((p->flags & BR_PROXYARP_WIFI) &&
>> +             if ((p->flags & BR_PROXYARP_WIFI ||
>> +                  p->flags & BR_NEIGH_SUPPRESS) &&
>>                   BR_INPUT_SKB_CB(skb)->proxyarp_replied)
>>                       continue;
>
> Don;t you need additional paren here to avoid warnings.
> Or do one mask:
>                 if ((p->flags & (BR_PROXYARP_WIFI | BR_NEIGH_SUPPRESS)) &&
>                     BR_INPUT_SKB_CB(skb)->proxyarp_replied)
>                         continue;

Missed seeing this, i just posted v3. I did not get a warning. I can
certainly simplify the mask and post.
