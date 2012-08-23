From: Roland Dreier <roland@kernel.org>
Subject: Re: Best way to set kernel thread affinity for handling a socket?
Date: Thu, 23 Aug 2012 10:04:51 -0700
Message-ID: <CAG4TOxOdTiahqVo6+cD=mCN5Ov_hLa_m5gBTuj5sUYsM+GgnYw@mail.gmail.com>
References: <CAG4TOxNMRR_-bYJV1a_je2HKrpmVuGubH9ks4GdG8Shwa92K0w@mail.gmail.com>
 <1345652493.2709.36.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:55136 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab2HWRFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 13:05:13 -0400
Received: by qaas11 with SMTP id s11so657074qaa.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 10:05:12 -0700 (PDT)
In-Reply-To: <1345652493.2709.36.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 22, 2012 at 9:21 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> With RFS we try to do the reverse: move the packets to match the socket
> user.   But it's not (yet) turned on by default.  See
> Documentation/networking/scaling.txt

Fair enough.  However I think at least in this case it sounds like extra
overhead: it should be easy for us to do everything on the CPU where
the packets are being received.

>> I'm thinking about this in the context of the kernel's iSCSI target
>> code (drivers/target/iscsi), which creates threads to handle each
>> iSCSI connection and sets their CPU affinity pretty much randomly
>> (well, based on some "thread id", cf iscsit_thread_get_cpumask()).
>
> Why set the affinity at all?

It's quite possible that, like a lot of other drivers/target code, this
doesn't actually make any sense and the right answer is to rip it
out completely.

Is the affinity due to waking up from a network receive event
enough to keep the threads local to the right CPU?

 - R.
