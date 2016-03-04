From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v3 0/3] NSH and VxLAN-GPE
Date: Fri, 4 Mar 2016 09:15:54 -0800
Message-ID: <CALx6S341571mCHJc_xgRC-qC0b6xpZ-mnV2eGyMZiKvPvTGTCQ@mail.gmail.com>
References: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Brian Russell <brussell@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34398 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbcCDRPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 12:15:55 -0500
Received: by mail-io0-f196.google.com with SMTP id l127so5572483iof.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 09:15:55 -0800 (PST)
In-Reply-To: <1456830709-32052-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 3:11 AM, Brian Russell <brussell@brocade.com> wrote:
> These patches add a new module to support encap/decap of Network
> Service Header (NSH) as defined in:
>
> https://tools.ietf.org/html/draft-ietf-sfc-nsh-01
>
> Both NSH Type 1 and Type 2 metadata are supported with a simple registration
> hook to allow listeners to register to see packets with Type 1 or a specific
> class of Type 2 metadata. NSH could be added to packets sent over a variety
> of link types, eg. VxLAN, GRE, ethernet.
>
> v2 - fix copyright notices and tidy up use of types
>
> v3 - fix various style issues in nsh module
>      remove VxLAN-GPE changes
>      add nsh logging module as example
>      add nsh netfilter encap target as example
>
> The previous version included mods to allow NSH over VxLAN-GPE but I've
> withdrawn this as VxLAN-GPE is currently being added in a much more complete
> patchset. My intention would be to add NSH support on top of that once it's
> applied.
>
What about NSH/GRE, NSH/Ethernet, and NSH/UDP?

> I've added the NSH logging module to illustrate the use of the simple
> mechanism to register for incoming decap'd NSH metadata.
>

Shouldn't that be in netfilter also?

> I've added the NSH netfilter target to illustrate metadata being NSH
> encap'd.
>
I think this patch set would be more compelling with an actual real
use case of SFC functionality. The ability to parse this stuff and
pass it to various layers or log that we are receiving it is nice and
all, but what is the functionality that we really need the kernel to
support here?

Tom

> Brian Russell (3):
>   nsh: encapsulation module
>   nsh: logging module
>   nsh: netfilter target
>
>  include/net/nsh.h                     | 147 +++++++++++++++
>  include/uapi/linux/if_ether.h         |   1 +
>  include/uapi/linux/netfilter/xt_NSH.h |  25 +++
>  net/ipv4/Kconfig                      |  18 ++
>  net/ipv4/Makefile                     |   2 +
>  net/ipv4/nsh.c                        | 335 ++++++++++++++++++++++++++++++++++
>  net/ipv4/nsh_log.c                    | 135 ++++++++++++++
>  net/netfilter/Kconfig                 |   9 +
>  net/netfilter/Makefile                |   1 +
>  net/netfilter/xt_NSH.c                |  95 ++++++++++
>  10 files changed, 768 insertions(+)
>  create mode 100644 include/net/nsh.h
>  create mode 100644 include/uapi/linux/netfilter/xt_NSH.h
>  create mode 100644 net/ipv4/nsh.c
>  create mode 100644 net/ipv4/nsh_log.c
>  create mode 100644 net/netfilter/xt_NSH.c
>
> --
> 2.1.4
>
