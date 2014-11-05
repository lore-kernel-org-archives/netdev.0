From: Cong Wang <cwang@twopensource.com>
Subject: Re: Can ndo_select_queue save data in skb->cb?
Date: Wed, 5 Nov 2014 10:38:51 -0800
Message-ID: <CAHA+R7M2k8_9C8=kdAJT1nSFDhKfV2HwvTo0nX-tVDJQvXjy+w@mail.gmail.com>
References: <545A64EC.309@openvpn.net>
	<1415211391.13896.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: James Yonan <james@openvpn.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:48508 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbaKESiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 13:38:52 -0500
Received: by mail-qg0-f45.google.com with SMTP id z107so12645010qgd.18
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 10:38:51 -0800 (PST)
In-Reply-To: <1415211391.13896.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014 at 10:16 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-11-05 at 10:57 -0700, James Yonan wrote:
>> Is it permissible for a net driver's ndo_select_queue method to save
>> data in skb->cb for later use in ndo_start_xmit?
>>
>> Also, is it necessary for users of skb->cb to zero out their private
>> data after use to prevent it from being misinterpreted by other layers?
>>   I noticed some commits in the log (such as 462fb2) are zeroing out the
>> skb->cb area for this reason.
>
> Its ok to use skb->cb[] from ndo_select_queue()
>
> Look at bond_select_queue() for such a case.
>
> You do not need to cleanup skb->cb[] to zero before giving skb to the
> driver.
>

That is only because qdisc layer saves data for bond,
which means if you have more data to save, you have to put
more into qdisc CB, it is just ugly.
