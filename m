From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2] ip_tunnel: Move stats update to iptunnel_xmit()
Date: Wed, 23 Dec 2015 20:37:57 -0800
Message-ID: <CALnjE+riaFcG1V+c-cvHxErrNYLJsfFHOrhp7CNsoARNTyLOqA@mail.gmail.com>
References: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
	<20151223.215712.2108576072504626201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35823 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbbLXEh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 23:37:58 -0500
Received: by mail-ig0-f169.google.com with SMTP id to4so92934469igc.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 20:37:58 -0800 (PST)
In-Reply-To: <20151223.215712.2108576072504626201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 6:57 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Wed, 23 Dec 2015 15:52:03 -0800
>
>>       } else {
>> -             err_stats->tx_dropped++;
>> +             struct net_device_stats *err_stats = &dev->stats;
>> +
>> +             if (err < 0) {
>> +                     err_stats->tx_errors++;
>> +                     err_stats->tx_aborted_errors++;
>> +             } else {
>> +                     err_stats->tx_dropped++;
>> +             }
>
> The original code did not have this "tx_dropped" code path
> and you aren't explaining in your commit message why you
> are adding this new behavior.

There is "tx_dropped" code path in existing iptunnel_xmit_stats(). I
have only moved err_stats variable definition to local block.
There is no new behavior in this patch.
