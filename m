From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Wed, 10 Jun 2015 13:53:30 +0900
Message-ID: <5577C2CA.2070702@miraclelinux.com>
References: <1433779259-14328-1-git-send-email-johunt@akamai.com>	<20150608.121601.1357405469784892473.davem@davemloft.net> <m2mw08kx7b.wl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, johunt@akamai.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, tom@herbertland.com
To: Hajime Tazaki <thehajime@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:42457 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752619AbbFJExf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 00:53:35 -0400
Received: by mail-pa0-f48.google.com with SMTP id qy3so26727690pab.3
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 21:53:35 -0700 (PDT)
In-Reply-To: <m2mw08kx7b.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hajime Tazaki wrote:
> 
> Hello Josh, Dave,
> 
> my mobile ipv6 test on libos failed with this commit.
> 
> This commit makes a destination option header handling (i.e.,
> ipprot->handler == ipv6_destopt_rcv) failed since
> ipv6_destopt_rcv() seems to return a positive value to
> indicate to goto resubmission label.
> 
> I will look for more detail.

I think we should look into other protocol handlers as well...

--yoshfuji

> 
> -- Hajime
> 
> At Mon, 08 Jun 2015 12:16:01 -0700 (PDT),
> David Miller wrote:
>>
>> From: Josh Hunt <johunt@akamai.com>
>> Date: Mon,  8 Jun 2015 12:00:59 -0400
>>
>>> UDP encapsulation is broken on IPv6. This is because the logic to resubmit
>>> the nexthdr is inverted, checking for a ret value > 0 instead of < 0. Also,
>>> the resubmit label is in the wrong position since we already get the
>>> nexthdr value when performing decapsulation. In addition the skb pull is no
>>> longer necessary either.
>>>
>>> This changes the return value check to look for < 0, using it for the
>>> nexthdr on the next iteration, and moves the resubmit label to the proper
>>> location.
>>>
>>> With these changes the v6 code now matches what we do in the v4 ip input
>>> code wrt resubmitting when decapsulating.
>>>
>>> Signed-off-by: Josh Hunt <johunt@akamai.com>
>>
>> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
