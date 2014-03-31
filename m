From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] net: ptp: oki-semi: fix build dependency
Date: Mon, 31 Mar 2014 13:19:36 -0700
Message-ID: <CAMEtUuxq5Q85jhUEE47+qjyLwaWPxJMy2A=rPo73HxPuO4SsZA@mail.gmail.com>
References: <1396288941-23063-1-git-send-email-ast@plumgrid.com>
	<20140331185538.GB7729@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:53954 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaCaUTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:19:37 -0400
Received: by mail-yk0-f177.google.com with SMTP id q200so6669312ykb.36
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 13:19:36 -0700 (PDT)
In-Reply-To: <20140331185538.GB7729@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 11:55 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Mar 31, 2014 at 11:02:21AM -0700, Alexei Starovoitov wrote:
>
>> Richard,
>> thank you for suggestion.
>> oki-semi depends on ptp, so it's cleaner to move ptp_classify_raw there,
>> instead of making it unconditionally available in net/core
>
>> Daniel,
>> timestamping has its own copy of PTP_FILTER, since timestamping
>> doesn't depend on ptp and I didn't want to add circular dependency,
>> since some of ptp pieces depend on timestamping, but not the others
>
> We don't really need two copies. As long as you are refactoring this,
> why not reduce it to just one filter?
>
> Something like
>
> #if defined(CONFIG_PTP_1588_CLOCK) || defined(CONFIG_NETWORK_PHY_TIMESTAMPING)
>
> ... code here ...
>
> #endif
>
> could go into filter.c or somewhere else in the stack.

Agree. two copies are not elegant, but #ifdef like above in filter.c
is even less elegant.
May be do net/core/Makefile:
-obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
+obj-y += timestamping.o
and add above #ifdefs to exclude most of the timestamping.c?
Any other options?
