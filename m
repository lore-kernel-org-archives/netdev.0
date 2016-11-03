From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net 1/1] driver: veth: Return the actual value instead
 return NETDEV_TX_OK always
Date: Thu, 3 Nov 2016 09:04:43 +0800
Message-ID: <CA+6hz4rPRgK=mcBkSK=tYrv_KcrYKJrD=EJW=UizMBBMfCETZw@mail.gmail.com>
References: <1478080756-16789-1-git-send-email-fgao@ikuai8.com>
 <CAM_iQpW4HmtoSAiKSyq9o0MXpL1R8XL2-r3NsPH6xu9Pd4X8XA@mail.gmail.com>
 <CA+6hz4rWLM_LkABr_cegdx66V2BBsR2Z7NuTMaDuBH2KZdOTSA@mail.gmail.com> <704bff33-d376-1825-07d1-b2e11775e9d4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        David Miller <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:57638 "EHLO
        smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751187AbcKCBEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 21:04:55 -0400
Received: from mail-ua0-f175.google.com (unknown [209.85.217.175])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:04:44 +0800 (CST)
Received: by mail-ua0-f175.google.com with SMTP id b35so27241563uaa.3
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 18:04:45 -0700 (PDT)
In-Reply-To: <704bff33-d376-1825-07d1-b2e11775e9d4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Thu, Nov 3, 2016 at 8:58 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/02/2016 05:52 PM, Gao Feng wrote:
>> Hi Cong,
>>
>> On Thu, Nov 3, 2016 at 4:22 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Wed, Nov 2, 2016 at 2:59 AM,  <fgao@ikuai8.com> wrote:
>>>> From: Gao Feng <fgao@ikuai8.com>
>>>>
>>>> Current veth_xmit always returns NETDEV_TX_OK whatever if it is really
>>>> sent successfully. Now return the actual value instead of NETDEV_TX_OK
>>>> always.
>>>>
>>>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>>>> ---
>>>>  drivers/net/veth.c | 7 +++++--
>>>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>>>> index fbc853e..769a3bd 100644
>>>> --- a/drivers/net/veth.c
>>>> +++ b/drivers/net/veth.c
>>>> @@ -111,15 +111,18 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
>>>>         struct veth_priv *priv = netdev_priv(dev);
>>>>         struct net_device *rcv;
>>>>         int length = skb->len;
>>>> +       int ret = NETDEV_TX_OK;
>>>>
>>>>         rcu_read_lock();
>>>>         rcv = rcu_dereference(priv->peer);
>>>>         if (unlikely(!rcv)) {
>>>>                 kfree_skb(skb);
>>>> +               ret = NET_RX_DROP;
>>>
>>>
>>> Returning NET_RX_DROP doesn't look correct in a xmit function.
>>
>> Yes. But I don't find good macro.
>> NETDEV_TX_BUSY or NET_RX_DROP, which is better ?
>
> There is no much choice you need to return a correct value from the
> netdev_tx_t enum, which NET_RX_DROP is not part of, so that probably
> means using NETDEV_TX_OK here, the packet has been freed, and there is
> no flow control problem mandating the return of NETDEV_TX_BUSY it seems...
> --
> Florian

Thanks your explanation.
It means the veth_xmit must return NETDEV_TX_OK.

Regards
Feng
