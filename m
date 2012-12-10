From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 5/5] smsc95xx: expand check_ macros
Date: Mon, 10 Dec 2012 09:16:22 +0000
Message-ID: <CAKh2mn7Bzii+ZCpBQtcyVfksAbLcjhZ0p7+oabfCG7-DV-6Cng@mail.gmail.com>
References: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
	<1354290952-27109-6-git-send-email-steve.glendinning@shawell.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70D4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53660 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab2LJJQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 04:16:23 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1394822eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 01:16:22 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70D4@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 December 2012 10:41, David Laight <David.Laight@aculab.com> wrote:
>> -             check_warn_return(ret, "Error reading MII_ACCESS\n");
>> +             if (ret < 0) {
>> +                     netdev_warn(dev->net, "Error reading MII_ACCESS\n");
>> +                     return ret;
>> +             }
>> +
>
> It might be worth defining something like:
>
> #define check_warn(dev, ret, errmsg) \
>         (ret >= 0 ? 0 : (netdev_warn(dev->net, errmsg), ret))
>
> so the above code can be:
>         if (check_warn(dev, ret, "Error reading MII_ACCESS\n"))
>                 return ret;
>

Thanks David, I'd rather not define this kind of macro locally though.
 I'm happy to use something like this but only if it's something
that's centrally defined, blessed by davem, and if it's something that
all drivers are intended to use.  Otherwise we end up with subtly
different macros in different drivers, and subtly different behaviours
in each.

Steve
