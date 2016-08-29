From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] ipv6: add missing netconf notif when 'all' is
 updated
Date: Mon, 29 Aug 2016 15:42:56 +0200
Message-ID: <9bb74290-07d9-8b7b-a039-7005f3b10cea@6wind.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
 <705293f5-0965-8d1c-1539-b70cbed6aea9@cogentembedded.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35430 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932908AbcH2NnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:43:00 -0400
Received: by mail-wm0-f48.google.com with SMTP id f65so79220951wmi.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 06:42:59 -0700 (PDT)
In-Reply-To: <705293f5-0965-8d1c-1539-b70cbed6aea9@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/08/2016 à 15:00, Sergei Shtylyov a écrit :
[snip]
>>      if (p == &net->ipv6.devconf_all->forwarding) {
>> +        int old_dftl = net->ipv6.devconf_dflt->forwarding;
>> +
>>          net->ipv6.devconf_dflt->forwarding = newf;
>> +        if ((!newf) ^ (!old_dftl))
> 
>    IIUC, !'s are not necessary here (and more so the parens around them). And
> perhaps ^ can be changed to != for clarity...
Yes, but a lot of places in this code use that. So for consistency I use the same.

> 
>> +            inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
>> +                             NETCONFA_IFINDEX_DEFAULT,
>> +                             net->ipv6.devconf_dflt);
>> +
>>          addrconf_forward_change(net, newf);
>>          if ((!newf) ^ (!old))
Here is an example.
