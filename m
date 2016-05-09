From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] ifstat: move to new RTM_GETSTATS api
Date: Sun, 08 May 2016 21:49:53 -0700
Message-ID: <573016F1.8050700@cumulusnetworks.com>
References: <1461998511-24193-1-git-send-email-roopa@cumulusnetworks.com> <57248720.8060001@mojatatu.com> <5724CC01.3030203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32911 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbcEIEt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:49:56 -0400
Received: by mail-pf0-f171.google.com with SMTP id 206so71833090pfu.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 21:49:56 -0700 (PDT)
In-Reply-To: <5724CC01.3030203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/30/16, 8:15 AM, Roopa Prabhu wrote:
> On 4/30/16, 3:21 AM, Jamal Hadi Salim wrote:
>> On 16-04-30 02:41 AM, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch modifies ifstat to use the new RTM_GETSTATS api
>>> to query stats from the kernel. In the process this also
>>> moves ifstat to use 64 bit stats.
>> Breaks old kernels? May need to keep backward compat of
>> RTM_NEWLINK and even new main struct for GETSTATS.
> yes, i was wondering about that. v2 coming. If GETSTATS fails, I will fallback to RTM_NEWLINK.
>
sorry abt the delay on this one. I hit a snag and could not get back to it last week.

AFAICS ifstat history file handling today assumes all 32 bit stats.
And to preserve backward compatibility, new ifstat should work with old and
new history files with 32bit and 64 bit stats.
The file format cannot be changed because of the same backward compat issues.
So, I am leaning towards a new history file with a new option (maybe ifstat -64) to
save/query 64 bit stats using the new api when available.

I see some previous brief discussions on moving ifstat to 64 bit.

The other option is to only change 'ip -s link show' to use the new stats api.

let me know if there are other thoughts.

thanks,
Roopa
