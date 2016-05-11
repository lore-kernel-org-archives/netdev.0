From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 net-next] ifstat: move to new RTM_GETSTATS api
Date: Wed, 11 May 2016 07:24:23 -0400
Message-ID: <57331667.5090208@mojatatu.com>
References: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com>
 <57248720.8060001@mojatatu.com> <5724CC01.3030203@cumulusnetworks.com>
 <573016F1.8050700@cumulusnetworks.com> <573084AC.6030407@mojatatu.com>
 <57320B6A.3090301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34614 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbcEKLYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 07:24:32 -0400
Received: by mail-io0-f193.google.com with SMTP id d62so5375916iof.1
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 04:24:31 -0700 (PDT)
In-Reply-To: <57320B6A.3090301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-10 12:25 PM, Roopa Prabhu wrote:
> On 5/9/16, 5:38 AM, Jamal Hadi Salim wrote:

>> Is it not possible to convert to 64b - and IFLA_STAT
>> becomes available just store it still in 64b?
>> i.e 32b will fit in 64b space.
>
> The only problem is again if the last saved history file had 32 bit
> and 32bit counters may roll over earlier.
>

I am not sure there is a good case of someone upgrading from 32b to 64b.

> One more thing i am looking at right now which might work is using
>   the existing history file and use the info_source (aka header) in ifstat history file to indicate
> 32bit or 64bit stats. For 32 bit it is currently "#kernel".
> For 64 bit i plan to use "#kernel64".
>

Good idea.

> If we are starting a new history file, i will always use 64bit and when using an existing history file,
> it will use 32bit.
>
> And 64bit stats will be queried with RTM_GETSTATS if available or will use IFLA_STATS64 when
> RTM_NEWLINK Is used.
>
> will see if i can get this working for all cases,

Yes, this would work.
Release it and see if someone is going to complain.

cheers,
jamal
