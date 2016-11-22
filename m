From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net 1/1] net: l2tp: Treat NET_XMIT_CN as success in l2tp_eth_dev_xmit
Date: Tue, 22 Nov 2016 14:32:49 +0800
Message-ID: <CA+6hz4ozH7GTZVv=4GnzSouXgW49J=PjrWYjAwPsSd8UN1s28Q@mail.gmail.com>
References: <1479689781-2125-1-git-send-email-fgao@ikuai8.com> <CAM_iQpX-z8Eja4rPg5dzAXLXd6v3nwMMPev-gk+wM9XLBNYK1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>, javier@osg.samsung.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpproxy19.qq.com ([184.105.206.84]:60463 "EHLO
        smtpproxy19.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbcKVGdT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 01:33:19 -0500
Received: from mail-ua0-f170.google.com (unknown [209.85.217.170])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 14:32:50 +0800 (CST)
Received: by mail-ua0-f170.google.com with SMTP id 51so6875065uai.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 22:32:51 -0800 (PST)
In-Reply-To: <CAM_iQpX-z8Eja4rPg5dzAXLXd6v3nwMMPev-gk+wM9XLBNYK1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Tue, Nov 22, 2016 at 1:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, Nov 20, 2016 at 4:56 PM,  <fgao@ikuai8.com> wrote:
>> From: Gao Feng <gfree.wind@gmail.com>
>>
>> The tc could return NET_XMIT_CN as one congestion notification, but
>> it does not mean the packe is lost. Other modules like ipvlan,
>> macvlan, and others treat NET_XMIT_CN as success too.
>> So l2tp_eth_dev_xmit should add the NET_XMIT_CN check.
>>
>> Signed-off-by: Gao Feng <gfree.wind@gmail.com>
>> ---
>>  net/l2tp/l2tp_eth.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
>> index 965f7e3..3dc97b4 100644
>> --- a/net/l2tp/l2tp_eth.c
>> +++ b/net/l2tp/l2tp_eth.c
>> @@ -97,7 +97,7 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
>>         unsigned int len = skb->len;
>>         int ret = l2tp_xmit_skb(session, skb, session->hdr_len);
>>
>> -       if (likely(ret == NET_XMIT_SUCCESS)) {
>> +       if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
>
> How could l2tp_xmit_skb() possibly return NET_XMIT_CN?
> Note It ignores the return value of l2tp_xmit_core().

You are right. I didn't think about it.

Regards
Feng
