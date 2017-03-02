From: Ani Sinha <ani@arista.com>
Subject: Re: ipv6 sysctl
Date: Thu, 2 Mar 2017 14:23:24 -0800
Message-ID: <CAOxq_8NjjrPffN7=iKSdvyCfTDBOaXxrb10cFbJgDmZzmvSd0Q@mail.gmail.com>
References: <CAOxq_8OwxVzV=s2zY4DUNDq8myA4kga7dZaqWbTyy+4j=1mMwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fruggeri <fruggeri@arista.com>, Jeff Chan <jchan@arista.com>,
        gilligan <gilligan@arista.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34393 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751476AbdCCHb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 02:31:29 -0500
Received: by mail-io0-f180.google.com with SMTP id 90so69570517ios.1
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 23:31:28 -0800 (PST)
In-Reply-To: <CAOxq_8OwxVzV=s2zY4DUNDq8myA4kga7dZaqWbTyy+4j=1mMwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey netdev guys,

Any feedback on this? :-)

thanks
ani


On Tue, Feb 28, 2017 at 11:22 AM, Ani Sinha <ani@arista.com> wrote:
> Hi guys,
>
> Commit a79ca223e029 ('ipv6: fix bad free of addrconf_init_net')
> introduced in linux 3.9 tries to fix an issue involving free-ing
> statically allocated memory. Additionally, it subtly changes behavior
> of how certain ipv6 sysctl values are inherited from the default net
> namespace to the child namespaces.   Before a79ca223e029, the default
> namespace would directly modify the values in statically allocated
> struct ipv6_devconf for example and all child namespaces would inherit
> these values upon creation (their own private copy was initialized
> using the statically allocated ipv6_devconf). After this change, any
> sysctl value changes in default net namespace is not seen by any new
> child namespaces that are created afterwards. This is because all
> network namespaces, including the default namespace has it's own
> private copy of  struct ipv6_devconf which is initialized by certain
> fixed values. This is in contrast to what we have in ipv4 where child
> namespaces continues to inherit values from the default namespace upon
> creation.
>
> I see that there was a previous discussion here :
> https://patchwork.kernel.org/patch/4639391/
>
> Was the above inconsistency between ipv4 and ipv6 sysctl
> initialization intentional or was it an unintended effect of the above
> change ? It would be nice to have a symmetric behavior between ipv4
> and ipv6. Please share your thoughts on this.
>
> thanks,
> ani
