From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Can ndo_select_queue save data in skb->cb?
Date: Wed, 05 Nov 2014 11:23:36 -0800
Message-ID: <545A7938.3070307@gmail.com>
References: <545A64EC.309@openvpn.net>  <1415211391.13896.10.camel@edumazet-glaptop2.roam.corp.google.com>  <CAHA+R7M2k8_9C8=kdAJT1nSFDhKfV2HwvTo0nX-tVDJQvXjy+w@mail.gmail.com> <1415213589.13896.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	James Yonan <james@openvpn.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:56796 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaKETX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 14:23:56 -0500
Received: by mail-oi0-f50.google.com with SMTP id v63so9267887oia.9
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 11:23:56 -0800 (PST)
In-Reply-To: <1415213589.13896.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 10:53 AM, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 10:38 -0800, Cong Wang wrote:
>> That is only because qdisc layer saves data for bond,
>> which means if you have more data to save, you have to put
>> more into qdisc CB, it is just ugly.
>
> Right, using skb->cb[] is ugly, dangerous, and all this.
>
> If you can, avoiding it is safer.
>
> Note that I pointed to the bonding case for a legal case,
> I had no time to do a full explanation, feel free to do so ;)
>

I would prefer to get rid of select_queue() versus expand
it. It mostly seems to be used for hacks around the stack
for FCoE/DCB/whatever. The wireless drivers and bonding/team
drivers are two examples where its not clear how to remove
it. See xen-netfront.c for an example where I'm not sure
why its needed at all.

James, why is your driver feeding itself data via cb? Maybe
we could solve the problem some other way.

Thanks,
John

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
