From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH iproute2 -next v2] ip: route: add congestion control metric
Date: Thu, 08 Jan 2015 00:37:48 +0100
Message-ID: <54ADC34C.9030505@redhat.com>
References: <1420630098-21621-1-git-send-email-dborkman@redhat.com> <20150107150657.1defa6bd@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754740AbbAGXh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 18:37:56 -0500
In-Reply-To: <20150107150657.1defa6bd@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 12:06 AM, Stephen Hemminger wrote:
> On Wed,  7 Jan 2015 12:28:18 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> +			if (i != RTAX_CC_ALGO)
>> +				val = *(unsigned *)RTA_DATA(mxrta[i]);
>
> Please use rta_getattr_u32 here.
>
> Yes, I know you copied old code, but the old code predated the helper
> functions.

No problem, that looks better indeed. Will add it.

Btw, while we're on the topic, we ignore errors for all rta_addattr*()
functions f.e. in iproute_modify(). I think at least we should undo the
mxlock in case of an error (or bail out entirely as a different option).

Thanks,
Daniel
