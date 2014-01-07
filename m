From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 1/9] xen-netback: Introduce TX grant map definitions
Date: Tue, 7 Jan 2014 14:50:59 +0000
Message-ID: <52CC1453.3090804@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <1386892097-15502-2-git-send-email-zoltan.kiss@citrix.com> <20131213153138.GL21900@zion.uk.xensource.com> <52AB506E.3040509@citrix.com> <20131213191423.GA12582@zion.uk.xensource.com> <52AF1A84.3090304@citrix.com> <20131216175036.GB25969@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:37892 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaAGOv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 09:51:29 -0500
In-Reply-To: <20131216175036.GB25969@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/12/13 17:50, Wei Liu wrote:
> On Mon, Dec 16, 2013 at 03:21:40PM +0000, Zoltan Kiss wrote:
> [...]
>>>>>>>
>>>>>>> Should this be BUG_ON? AIUI this kthread should be the only one doing
>>>>>>> unmap, right?
>>>>> The NAPI instance can do it as well if it is a small packet fits
>>>>> into PKT_PROT_LEN. But still this scenario shouldn't really happen,
>>>>> I was just not sure we have to crash immediately. Maybe handle it as
>>>>> a fatal error and destroy the vif?
>>>>>
>>> It depends. If this is within the trust boundary, i.e. everything at the
>>> stage should have been sanitized then we should BUG_ON because there's
>>> clearly a bug somewhere in the sanitization process, or in the
>>> interaction of various backend routines.
>>
>> My understanding is that crashing should be avoided if we can bail
>> out somehow. At this point there is clearly a bug in netback
>> somewhere, something unmapped that page before it should have
>> happened, or at least that array get corrupted somehow. However
>> there is a chance that xenvif_fatal_tx_err() can contain the issue,
>> and the rest of the system can go unaffected.
>>
>
> That would make debugging much harder if a crash is caused by a previous
> corrupted array and we pretend we can carry on serving IMHO. Now netback
> is having three routines (NAPI, two kthreads) to serve a single vif, the
> interation among them makes bug hard to reproduce.

OK, I'll make this a BUG() in the next series.

Zoli
