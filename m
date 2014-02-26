From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RESEND] [PATCH v4] sh_eth: update OF PHY registeration
Date: Wed, 26 Feb 2014 11:05:00 -0800
Message-ID: <CAGVrzcYHF_5Ovz2AnNshQ508OqKjiX5Yf0H4ZfXjayWCtQmN8w@mail.gmail.com>
References: <1393439008-26698-1-git-send-email-ben.dooks@codethink.co.uk> <530E44BA.8090209@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	netdev <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damn@opensource.se,
	Simon Horman <horms@verge.net.au>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33244 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbaBZTFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 14:05:45 -0500
In-Reply-To: <530E44BA.8090209@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-26 11:47 GMT-08:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
[snip]

>> +               pn = of_parse_phandle(np, "phy-handle", 0);
>> +               phydev = of_phy_connect(ndev, pn,
>> +                                       sh_eth_adjust_link, 0,
>
>
>    Hm, that 0 corresponds to 'flags' parameter which is not used. I wonder
> if that was intentional...

This is a left-over from when we needed to set phydev->dev_flags, but
this is no longer necessary although of_phy_connect() kept the
argument. Setting phydev->dev_flags should be done before calling
phy_start(), so far we only have a two users in-tree: tg3.c and some
mach-pxa code doing that.

>
>
>> +                                       mdp->phy_interface);
>> +
>> +               if (!phydev)
>> +                       phydev = ERR_PTR(-ENOENT);

Sounds like this could be moved to of_phy_connect(), although not
necessarily as part of this patchset, also, we would need to update
the callers, but this would be more consistent.
-- 
Florian
