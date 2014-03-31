From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] net: ptp: oki-semi: fix build dependency
Date: Tue, 01 Apr 2014 00:26:13 +0200
Message-ID: <5339EB85.4050308@redhat.com>
References: <1396288941-23063-1-git-send-email-ast@plumgrid.com> <20140331185538.GB7729@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbaCaW0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 18:26:23 -0400
In-Reply-To: <20140331185538.GB7729@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2014 08:55 PM, Richard Cochran wrote:
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

I'd move that code into it's own file e.g. ptp_classifier.c and while
at it also remove PTP_FILTER stuff from the header file entirely and
hide it all locally in that file. I will cook something tomorrow.

Cheers,

Daniel
