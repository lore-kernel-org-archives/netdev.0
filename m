From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC net-next 0/4] bridge: improve cache utilization
Date: Tue, 31 Jan 2017 10:21:37 -0800
Message-ID: <20170131102137.5659d280@xeon-e3>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
        <20170131083919.51a3ac9f@xeon-e3>
        <31c4c454-b0e5-5a84-ffce-c8b39fa2d301@cumulusnetworks.com>
        <2c59b56a-4a8b-0f32-31d1-1e8c44643958@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32909 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdAaSVq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:21:46 -0500
Received: by mail-pf0-f178.google.com with SMTP id y143so109455502pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:21:45 -0800 (PST)
In-Reply-To: <2c59b56a-4a8b-0f32-31d1-1e8c44643958@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Jan 2017 19:09:09 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> On 31/01/17 17:41, Nikolay Aleksandrov wrote:
> >>
> >> I agree with the first 3 patches, but not the last one.
> >> Changing the API just for a performance hack is not necessary. Instead make
> >> the algorithm smarter and use per-cpu values.
> >>  
> > 
> > Thanks for the feedback, I would very much prefer any of the other two approaches
> > I tried (per-cpu pool and per-cpu for each fdb), from the two the second one -
> > per-cpu for each fdb is much simpler, so would it be acceptable to do per-cpu allocation
> > for each fdb ?
> > 
> > 
> >   
> 
> Okay, after some more testing the version with per-cpu per-fdb allocations, at 300 000 fdb entries
> I got 120 failed per-cpu allocs which seems okay. I'll wait a little more and will repost the series
> with per-cpu allocations and without the RFC tag.
> 
> Thanks,
>  Nik
> 

You could also use a mark/sweep algorithm (rather than recording updated).
It turns out that clearing is fast (can be unlocked).
The timer workqueue can mark all fdb entries (during scan), then in forward
function clear the bit if it is set. This would turn writes into reads.

To keep the API for last used, just change the resolution to be scan interval.
