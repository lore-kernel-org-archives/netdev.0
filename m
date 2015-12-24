From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ip_tunnel: Move stats update to
 iptunnel_xmit()
Date: Thu, 24 Dec 2015 10:03:12 +0100
Message-ID: <567BB4D0.8040203@6wind.com>
References: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
 <20151223.215712.2108576072504626201.davem@davemloft.net>
 <CALnjE+riaFcG1V+c-cvHxErrNYLJsfFHOrhp7CNsoARNTyLOqA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37424 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbbLXJDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:03:15 -0500
Received: by mail-wm0-f45.google.com with SMTP id p187so176118068wmp.0
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 01:03:14 -0800 (PST)
In-Reply-To: <CALnjE+riaFcG1V+c-cvHxErrNYLJsfFHOrhp7CNsoARNTyLOqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/12/2015 05:37, Pravin Shelar a =C3=A9crit :
> On Wed, Dec 23, 2015 at 6:57 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Wed, 23 Dec 2015 15:52:03 -0800
>>
>>>        } else {
>>> -             err_stats->tx_dropped++;
>>> +             struct net_device_stats *err_stats =3D &dev->stats;
>>> +
>>> +             if (err < 0) {
>>> +                     err_stats->tx_errors++;
>>> +                     err_stats->tx_aborted_errors++;
>>> +             } else {
>>> +                     err_stats->tx_dropped++;
>>> +             }
>>
>> The original code did not have this "tx_dropped" code path
>> and you aren't explaining in your commit message why you
>> are adding this new behavior.
>
> There is "tx_dropped" code path in existing iptunnel_xmit_stats(). I
> have only moved err_stats variable definition to local block.
> There is no new behavior in this patch.
>
Yes, I think it's ok now. There is no functional change. The prototype
of the function has changed: err_stats is not provided anymore in the a=
rguments.
