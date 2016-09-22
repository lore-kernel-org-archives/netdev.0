From: Juergen Gross <jgross@suse.com>
Subject: Re: [Xen-devel] [PATCH resend] xen-netback: switch to threaded irq
 for control ring
Date: Thu, 22 Sep 2016 12:39:24 +0200
Message-ID: <a6111109-2f9f-d804-8040-bde575d2a769@suse.com>
References: <1474534964-15621-1-git-send-email-jgross@suse.com>
 <37d32749052f4ff887c5637671085389@AMSPEX02CL03.citrite.net>
 <2f3c7f1b-6a36-8aaa-e10a-41a1d2cf37d8@suse.com>
 <78418d2acd0446e8bbbd634377b9e263@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37178 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753122AbcIVKj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 06:39:27 -0400
In-Reply-To: <78418d2acd0446e8bbbd634377b9e263@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/09/16 12:31, Paul Durrant wrote:
>> -----Original Message-----
>> From: Juergen Gross [mailto:jgross@suse.com]
>> Sent: 22 September 2016 11:17
>> To: Paul Durrant <Paul.Durrant@citrix.com>; xen-devel@lists.xenproject.org;
>> netdev@vger.kernel.orga <netdev@vger.kernel.org>; linux-
>> kernel@vger.kernel.org
>> Cc: Wei Liu <wei.liu2@citrix.com>
>> Subject: Re: [Xen-devel] [PATCH resend] xen-netback: switch to threaded irq
>> for control ring
>>
>> On 22/09/16 11:09, Paul Durrant wrote:
>>>> -----Original Message-----
>>>> From: Xen-devel [mailto:xen-devel-bounces@lists.xen.org] On Behalf Of
>>>> Juergen Gross
>>>> Sent: 22 September 2016 10:03
>>>> To: xen-devel@lists.xenproject.org; netdev@vger.kernel.orga; linux-
>>>> kernel@vger.kernel.org
>>>> Cc: Juergen Gross <jgross@suse.com>; Wei Liu <wei.liu2@citrix.com>
>>>> Subject: [Xen-devel] [PATCH resend] xen-netback: switch to threaded
>>>> irq for control ring
>>>>
>>>> Instead of open coding it use the threaded irq mechanism in xen-netback.
>>>>
>>>> Signed-off-by: Juergen Gross <jgross@suse.com>
>>>
>>> How have you tested this change?
>>
>> Only compile-tested and loaded the module. As this feature isn't being used
>> in linux netfront AFAIK it is not easily testable. OTOH the code modification is
>> rather limited and I've used the threaded irq in the Xen scsiback driver
>> myself, so I'm rather confident it will work.
>>
> 
> OK. How about doing the rx interrupt/task too so that it can be easily tested with a linux netfront?

I'd like to, but this would require some more work. The rx kthread isn't
activated by an event only, but by a timer, too. This isn't easy to map
to the threaded irq framework. If, however, you are confident the timer
isn't really necessary I'd be happy to provide a patch switching the
rx task to the threaded irq, too.

And to be honest: this wouldn't verify that the control ring related
patch is really working. The mechanism itself _is_ working as it is
already in use in xen-scsiback in a very similar environment.


Juergen
