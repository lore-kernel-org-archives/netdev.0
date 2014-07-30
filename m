From: Florian Fainelli <f.fainelli@gmail.com>
Subject: linux/if_bridge.h no longer self contained (again)
Date: Wed, 30 Jul 2014 15:05:01 -0700
Message-ID: <CAGVrzcamm6bgTc_-1OZGD0L4DqQd5RfoVYftZic3MDvD8YMjxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eblake@redhat.com, Kumar Gala <galak@codeaurora.org>
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Gregory Fong <gregory.0xf0@gmail.com>, carlos@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:52397 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbaG3WFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 18:05:42 -0400
Received: by mail-ob0-f178.google.com with SMTP id nu7so997055obb.23
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 15:05:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Gregory and I bumped into the following issue:

http://linux-kernel.2935.n7.nabble.com/if-bridge-h-include-in6-h-for-struct-in6-addr-use-td580828.html

also reported here: https://bugzilla.redhat.com/show_bug.cgi?id=895141

We tracked down the following Linux changes:

ee262ad827f89e2dc7851ec2986953b5b125c6bc  inet: defines IPPROTO_*
needed for module alias generation
cfd280c91253cc28e4919e349fa7a813b63e71e8  net: sync some IP headers with glibc

and the following glibc change:

6c82a2f8d7c8e21e39237225c819f182ae438db3  Coordinate IPv6 definitions
for Linux and glibc

but as far as we could see and test it, this particular issue is still
present in the current Linux kernel.

What would be the recommended ways to move forward?

Should we keep a local change that includes netinet/in6.h and just
hope it does not cause any re-definitions?

Thanks!
-- 
Florian
