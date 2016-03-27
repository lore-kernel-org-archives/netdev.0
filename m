From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH -next 0/5] netlink: remove mmapped netlink support
Date: Sun, 27 Mar 2016 09:32:05 +0200
Message-ID: <CAFLxGvxxDFHoxZM0OQkrPhKbFFuvN6cV4VLcDLsoqt-r=4D2UA@mail.gmail.com>
References: <1455804208-30512-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f196.google.com ([209.85.214.196]:33068 "EHLO
	mail-ob0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778AbcC0HcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 03:32:07 -0400
Received: by mail-ob0-f196.google.com with SMTP id do7so7624371obb.0
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 00:32:06 -0700 (PDT)
In-Reply-To: <1455804208-30512-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 3:03 PM, Florian Westphal <fw@strlen.de> wrote:
> As discussed during netconf 2016 in Seville, this series removes
> CONFIG_NETLINK_MMAP.

Sorry for hopping in so^Wtoo late.
I always thought mmaped netlink is the way to go for
userspace packet processing.
Sure, the problems you state are real but that the whole concept
is now thrown away kind of surprises me.

> Close to three years after it was merged it has retained several problems
> that do not appear to be fixable.
>
> No official netfilter libmnl release contains support for mmap backed netlink
> sockets. No openvswitch release makes use of it either.
>
> To use the mmap interface, userspace not only has to probe for mmap netlink
> support, it also has to implement a recv/socket receive path in order to
> handle messages that exceed the size of an rx ring element (NL_MMAP_STATUS_COPY).
>
> So if there are odd programs out there that attempt to use MMAP netlink
> they should continue to work as they already need a socket based code path
> to work properly.
>
> The actual revert (first patch) has a list of problems.
> The followup patches remove a couple of helpers that are no longer needed
> after the revert.
>
> I did a few tests with mmap vs. socket based interface on a 4.4 based
> kernel on an i7-4790 box and there are no performance advantages:

Did you also test smaller devices?
i.e. stuff one would use for cheap routers.

-- 
Thanks,
//richard
