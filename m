From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH iproute2 -next] ip: route: add congestion control metric
Date: Wed, 07 Jan 2015 11:21:29 +0100
Message-ID: <54AD08A9.9000205@redhat.com>
References: <1420588357-17665-1-git-send-email-dborkman@redhat.com> <20150106170926.5bb2d816@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbbAGKVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 05:21:45 -0500
In-Reply-To: <20150106170926.5bb2d816@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2015 02:09 AM, Stephen Hemminger wrote:
> On Wed,  7 Jan 2015 00:52:37 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> +		} else if (matches(*argv, "congctl") == 0) {
>> +			char cc[16];
>> +			NEXT_ARG();
>> +			memset(cc, 0, sizeof(cc));
>> +			if (strcmp(*argv, "lock") == 0) {
>> +				mxlock |= (1<<RTAX_CC_ALGO);
>
> Unneeded paren

Yep, I kept it consistent across all mxlock assignments of this file,
but I can remove it, sure.

>> +				NEXT_ARG();
>> +			}
>> +			strncpy(cc, *argv, sizeof(cc) - 1);
>> +			if (strlen(cc) == 0)
>> +				invarg("\"conctl\" value must be an algorithm name\n", *argv
>
> Silently truncating the string is not odd. Can't we just let kernel impose
> length restrictions.

Sure, will respin, thanks.
