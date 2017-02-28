From: Ani Sinha <ani@arista.com>
Subject: ipv6 sysctl
Date: Tue, 28 Feb 2017 11:22:45 -0800
Message-ID: <CAOxq_8OwxVzV=s2zY4DUNDq8myA4kga7dZaqWbTyy+4j=1mMwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fruggeri <fruggeri@arista.com>, Jeff Chan <jchan@arista.com>,
        gilligan <gilligan@arista.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36831 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdB1VJV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:09:21 -0500
Received: by mail-it0-f45.google.com with SMTP id h10so85167555ith.1
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 13:09:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

Commit a79ca223e029 ('ipv6: fix bad free of addrconf_init_net')
introduced in linux 3.9 tries to fix an issue involving free-ing
statically allocated memory. Additionally, it subtly changes behavior
of how certain ipv6 sysctl values are inherited from the default net
namespace to the child namespaces.   Before a79ca223e029, the default
namespace would directly modify the values in statically allocated
struct ipv6_devconf for example and all child namespaces would inherit
these values upon creation (their own private copy was initialized
using the statically allocated ipv6_devconf). After this change, any
sysctl value changes in default net namespace is not seen by any new
child namespaces that are created afterwards. This is because all
network namespaces, including the default namespace has it's own
private copy of  struct ipv6_devconf which is initialized by certain
fixed values. This is in contrast to what we have in ipv4 where child
namespaces continues to inherit values from the default namespace upon
creation.

I see that there was a previous discussion here :
https://patchwork.kernel.org/patch/4639391/

Was the above inconsistency between ipv4 and ipv6 sysctl
initialization intentional or was it an unintended effect of the above
change ? It would be nice to have a symmetric behavior between ipv4
and ipv6. Please share your thoughts on this.

thanks,
ani
