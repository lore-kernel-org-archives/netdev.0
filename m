From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] fix rtnl notification in atomic context
Date: Wed, 23 Oct 2013 14:25:17 -0700
Message-ID: <CAMEtUuw+TtVcShem=rxSGu3JhEx60jeGFBrhWSXT6XuyYODGeA@mail.gmail.com>
References: <1382553161-3498-1-git-send-email-ast@plumgrid.com>
	<20131023140343.4604d80d@nehalam.linuxnetplumber.net>
	<20131023.170919.2254167416151180538.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	amwang@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:40075 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3JWVZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 17:25:19 -0400
Received: by mail-wi0-f180.google.com with SMTP id ey11so1596467wid.13
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 14:25:18 -0700 (PDT)
In-Reply-To: <20131023.170919.2254167416151180538.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 2:09 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 23 Oct 2013 14:03:43 -0700
>
>> On Wed, 23 Oct 2013 11:32:41 -0700
>> Alexei Starovoitov <ast@plumgrid.com> wrote:
>>
>>> +
>>> +void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change)
>>> +{
>>> +    __rtmsg_ifinfo(type, dev, change, GFP_KERNEL);
>>> +}
>>>  EXPORT_SYMBOL(rtmsg_ifinfo);
>>>
>>>  static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
>>> --
>>
>> Why add another wrapper function? I think it cleaner to just change all the
>> callers to use the correct gfp flags.
>
> Indeed, if this were targetted to "net" we'd have the argument of trying
> to simplify the patch for -stable inclusion.
>
> But since this is going into net-next, let's just put explicit GFP_* args
> at the call site.

sure. Will respin.
