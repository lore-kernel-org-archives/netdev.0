From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Fri, 21 Jul 2017 14:53:21 -0700
Message-ID: <CAJieiUgQZbwj_xjKGQd6ibHDn87mgWxTgRNZs8g+rqONC6nX=A@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com> <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:37931 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdGUVxW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 17:53:22 -0400
Received: by mail-ua0-f175.google.com with SMTP id w45so54205094uac.5
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 14:53:22 -0700 (PDT)
In-Reply-To: <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 21, 2017 at 11:42 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Jul 20, 2017 at 8:23 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
>> 2017-07-20 23:06 GMT+08:00 Hangbin Liu <liuhangbin@gmail.com>:
>>>> +++ b/net/ipv6/route.c
>>>> @@ -3637,12 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>>>>                 dst = ip6_route_lookup(net, &fl6, 0);
>>>>
>>>>         rt = container_of(dst, struct rt6_info, dst);
>>>> -       if (rt->dst.error) {
>>>> -               err = rt->dst.error;
>>>> -               ip6_rt_put(rt);
>>>> -               goto errout;
>>>> -       }
>>>
>>> hmm... or instead of remove this check, should we check all the entry? Like
>>> if ((rt->dst.error && rt != net->ipv6.ip6_null_entry && rt !=
>>                                                     ^^ mistake here
>>> net->ipv6.ip6_blk_hole_entry) ||
>>>      rt == net->ipv6.ip6_null_entry )
>>
>> Sorry,  there should be no need to check ip6_null_entry since the
>> error is already
>> -ENETUNREACH. So how about
>
> Hmm? All of these 3 entries have error set, right??
> So we should only check dst.error...

removing the check seems ok to me. We can also make the check
conditional to fibmatch code only
to eliminate any change in behavior introduced by fibmatch.

ie if (fibmatch && rt->dst.error).

Hangbin, can you also pls check that fibmatch works ok for such routes
with your patch applied ?.

ip netns exec client ip -6 route get fibmatch 2003::1     (with latest iproute2)

thank you.
