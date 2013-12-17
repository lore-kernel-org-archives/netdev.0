From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH -next] xen-netback: fix some error return code
Date: Tue, 17 Dec 2013 10:32:15 +0800
Message-ID: <CAPgLHd8v1z9nQzR5MAZ2ZdwudSzL_p4+=KTjyJsqJVkB3ohHLw@mail.gmail.com>
References: <CAPgLHd9aQQq-gLuNzGaYP2TSz=5Xk_GqgS=MSrAB7Tnn0nCydw@mail.gmail.com>
	<20131216131313.GE12582@zion.uk.xensource.com>
	<1387201238.10247.37.camel@kazak.uk.xensource.com>
	<CAPgLHd_yD=s0xKXop8T47hvxw2MZD9PHZ9tKKB+45Y5uOHNUVQ@mail.gmail.com>
	<1387203160.21086.1.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: wei.liu2@citrix.com, yongjun_wei@trendmicro.com.cn,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45369 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab3LQCcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 21:32:17 -0500
Received: by mail-bk0-f46.google.com with SMTP id u15so2636122bkz.33
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 18:32:15 -0800 (PST)
In-Reply-To: <1387203160.21086.1.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 10:12 PM, Ian Campbell wrote:
> On Mon, 2013-12-16 at 21:57 +0800, Wei Yongjun wrote:
>> On 12/16/2013 09:40 PM, Ian Campbell wrote:
>>> On Mon, 2013-12-16 at 13:13 +0000, Wei Liu wrote:
>>>> On Mon, Dec 16, 2013 at 01:49:29PM +0800, Wei Yongjun wrote:
>>>>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>>>>
>>>>> Fix to return -EPROTO error code instead of 0(overwrite by maybe_pull_tail())
>>>>> if skb_partial_csum_set() return false.
>>>>>
>>>>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>>>> ---
>>>>>  drivers/net/xen-netback/netback.c | 16 ++++++++++++----
>>>>>  1 file changed, 12 insertions(+), 4 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
>>>>> index 800496b..b16daa7 100644
>>>>> --- a/drivers/net/xen-netback/netback.c
>>>>> +++ b/drivers/net/xen-netback/netback.c
>>>>> @@ -1108,8 +1108,10 @@ static int checksum_setup_ip(struct xenvif *vif, struct sk_buff *skb,
>>>>>  			goto out;
>>>>>  
>>>>>  		if (!skb_partial_csum_set(skb, off,
>>>>> -					  offsetof(struct tcphdr, check)))
>>>>> +					  offsetof(struct tcphdr, check))) {
>>>>> +			err = -EPROTO;
>>>> Why is this needed? It is set to -EPROTO before the 'switch'.
>>> Agreed.
>> As I said in the description, err is overwrited to 0 by the above
>> 'err = maybe_pull_tail(...)' call in the same 'case XXX'.
>> Refer to the source code:
> What tree/commit is this? Neither Linus', net or net-next look like this
> to me.

Sorry, I used linux-next tree for this patch. It looks like the linux.git and net tree
has this code, but not net-next.

This commit cause this issue:
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/drivers/net/xen-netback/netback.c?id=d52eb0d46f3606b9de9965cebb2beb2202a0dc62

So this patch is need for net tree, not net-next. I will rebased this
patch with description changed.
