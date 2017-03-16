From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same sk_rx_dst.
Date: Thu, 16 Mar 2017 11:45:03 +0100
Message-ID: <87fuidv6ts.fsf@redhat.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com> <87h92tv8uv.fsf@redhat.com> <242C9F89-8639-4C31-B3E5-B56C4F785E41@hulu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Kevin Xu <kaiwen.xu@hulu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35197 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdCPKpH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:45:07 -0400
Received: by mail-wm0-f41.google.com with SMTP id u132so31578578wmg.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 03:45:06 -0700 (PDT)
In-reply-to: <242C9F89-8639-4C31-B3E5-B56C4F785E41@hulu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 10:12 AM GMT, Kevin Xu wrote:
> Do you mean the message looping endlessly?

No, the message is emitted just once. Around 100 seconds after
destroying a few namespaces. Occurs not so often, maybe once per ten
runs.

-Jakub

> If so, then I suppose it's a different bug.
>
> Kevin
>
>> On Mar 16, 2017, at 3:01 AM, Jakub Sitnicki <jkbs@redhat.com> wrote:
>>
>>> On Thu, Mar 16, 2017 at 08:08 AM GMT, Kevin Xu wrote:
>>> In some rare cases, inet_sk_rx_dst_set() may be called multiple times
>>> on the same dst, causing reference count leakage. Eventually, it
>>> prevents net_device to be destroyed. The bug then manifested as
>>>
>>> unregister_netdevice: waiting for lo to become free. Usage count = 1
>>>
>>> in the kernel log, preventing new network namespace creation.
>>>
>>> The patch works around the issue by checking whether the socket already
>>> has the same dst set.
>>>
>>> Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
>>> ---
>>
>> FWIW, with this patch applied I'm still sometimes seeing:
>>
>> [  125.928095] unregister_netdevice: waiting for lo to become free. Usage count = 1
>>
>> -Jakub
