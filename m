From: Cong Wang <cwang@twopensource.com>
Subject: Re: iproute2: ip netns: Do not delete netns if there any process use it
Date: Wed, 11 Mar 2015 09:38:04 -0700
Message-ID: <CAHA+R7Pwfjg4642i1FMG1mKJN58K+nYhqvN_NnrbQ+uiPXibGQ@mail.gmail.com>
References: <20150311074020.GA26477@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33671 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbbCKQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:38:04 -0400
Received: by iecvj10 with SMTP id vj10so3356597iec.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 09:38:04 -0700 (PDT)
In-Reply-To: <20150311074020.GA26477@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 12:40 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
>
> Hi,
>
> There might be case when it is possible to loose device which was
> moved to netns if there is process which is running is that netns:
>
>     $ ip netns add net
>     $ ip link set dev eth0 netns net0
>     $ ip netns exec net0 SOME_PROCESS_IN_BACKGROUND
>     $ ip netns del net0
>
> so eth0 will not appear in the default netns until SOME_PROCESS_IN_BACKGROUND will exit or
> will ne killed. So to avoid such case it might be better to do not
> delete netns if there are process in it ? I meant add such validation
> for 'ip netns del' command.

No, kernel does all the reference counting, no need to bother iproute2.
