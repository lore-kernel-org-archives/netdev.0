From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 04 May 2017 11:36:36 +0200
Message-ID: <590AF624.6090808@iogearbox.net>
References: <20170503235638.31116-1-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59230 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751407AbdEDJgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 05:36:38 -0400
In-Reply-To: <20170503235638.31116-1-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2017 01:56 AM, Stephen Hemminger wrote:
> Add support for extended ack error reporting via libmnl. This
> is a better alternative to use existing library and not copy/paste
> code from the kernel. Also make arguments const where possible.
>
> Add a new function rtnl_talk_extack that takes a callback as an input
> arg. If a netlink response contains extack attributes, the callback is
> is invoked with the the err string, offset in the message and a pointer
> to the message returned by the kernel.
>
> Adding a new function allows commands to be moved over to the
> extended error reporting over time.
>
> For feedback, compile tested only.

Just out of curiosity, what is the plan regarding converting iproute2
over to libmnl (ip, tc, ss, ...)? In 2015, tipc tool was the first
user merged that requires libmnl, the only other user today in the
tree is devlink, which even seems to define its own libmnl library
helpers. What is the clear benefit/rationale of outsourcing this to
libmnl? I always was the impression we should strive for as little
dependencies as possible?

I don't really like that we make extended ack reporting now dependent
on libmnl, which further diverts from iproute's native nl library vs
requiring to install another nl library, making the current status
quo even worse ... :/

Thanks,
Daniel
