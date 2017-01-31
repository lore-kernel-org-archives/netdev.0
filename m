From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when processing
 rtnl_newlink
Date: Tue, 31 Jan 2017 13:25:32 -0700
Message-ID: <6a71762b-3e3b-06e6-9b9b-9b00cdbb2cf8@cumulusnetworks.com>
References: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
 <CAM_iQpW1+UK+ykB3s-yqi+ozR-BuRTvQ6hX1XmkMvAXSWEgkrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32824 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751281AbdAaUfV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 15:35:21 -0500
Received: by mail-pf0-f169.google.com with SMTP id y143so110986672pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 12:34:21 -0800 (PST)
In-Reply-To: <CAM_iQpW1+UK+ykB3s-yqi+ozR-BuRTvQ6hX1XmkMvAXSWEgkrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 11:49 PM, Cong Wang wrote:
> On Mon, Jan 30, 2017 at 3:23 PM, Theuns Verwoerd
> <theuns.verwoerd@alliedtelesis.co.nz> wrote:
>> @@ -2653,6 +2653,11 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
>>                         if (err < 0)
>>                                 goto out_unregister;
>>                 }
>> +               if (tb[IFLA_MASTER]) {
>> +                       err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
>> +                       if (err)
>> +                               goto out_unregister;
>> +               }
>>  out:
>>                 if (link_net)
>>                         put_net(link_net);
> 
> Not sure if it is too late to call do_set_master() after
> dev_change_net_namespace().
> 

The master device index is relative to a namespace. If both are given then the namespace change must be done first.
