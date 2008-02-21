From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Thu, 21 Feb 2008 08:59:59 +0000
Message-ID: <20080221085959.GA12944@ff.dom.local>
References: <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:62635 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbYBUI7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 03:59:08 -0500
Received: by an-out-0708.google.com with SMTP id d31so725776and.103
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 00:59:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47BCABC5.9080204@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2008 at 10:37:57PM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
>
>>>> (testing patch #1)
>>
>> But I hope you tested with the fixed (take 2) version of this patch...
>
> Yes I did. :)
>
> But I just got another lockdep error (attached).
>
>> Since it's quite experimental (testing) this patch could be wrong
>> as it is, but I hope it should show the proper way to solve this
>> problem. Probably you did some of these, but here are a few of my
>> suggestions for testing this:
>>
>> 1) try my patch with your full bh locking changing patch;
>> 2) add while loops to these trylocks on failure, with e.g.  __delay(1);
>>    this should work like full locks again, but there should be no (this
>>    kind of) lockdep reports;
>
> Hmm, isn't this just bypassing the lockdep checks?

Yes! But it's only for debugging: to find if this change in locking
is to be blamed for these new lockups. It should effectively work just
like without this patch, but without this lockdep warning. So, if
after such change lockups still happen, then it would seem you didn't
test this enough before. Otherwise the new patch is to blame and needs
reworking.

>
>> 3) I send here another testing patch with this second way to do this:
>>    on the write side, but it's even more "experimental" and only a
>>    proof of concept (should be applied on vanilla ppp_generic).
>
> I'll look over it. I think I need to take a step back and look at what's  
> happening in more detail though.

This is something completely new and changes all the picture: the xmit
path wasn't expected (at least by me) to be called in softirq context
at all, and there were no traces of this on previous reports. But,
since lockdep always stops after the first warning, there could be
even more surprises like this in the future. I'll check this report.

Regards,
Jarek P.
