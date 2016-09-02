From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 17:00:26 +0100
Message-ID: <20160902160026.GT2356@ZenIV.linux.org.uk>
References: <871t13o1n1.fsf@doppelsaurus.mobileactivedefense.com>
 <CA+55aFzbCDwOTbHiawpY2xSaR_EBkTDbYeJV3CH09OLLtPW3nw@mail.gmail.com>
 <6f7d587b-3933-7c02-a804-db1732ced1cf@stressinduktion.org>
 <CA+55aFyNJg_brA4rGF0S2ve0V_2vuhZCFKEMFDNhHKEXoVCRGA@mail.gmail.com>
 <20160901204746.GR2356@ZenIV.linux.org.uk>
 <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com>
 <20160901210142.GS2356@ZenIV.linux.org.uk>
 <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com>
 <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
 <87lgzae3f7.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        CAI Qian <caiqian@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Rainer Weikusat <rweikusat@cyberadapt.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58078 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932371AbcIBQAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 12:00:36 -0400
Content-Disposition: inline
In-Reply-To: <87lgzae3f7.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2016 at 04:18:04PM +0100, Rainer Weikusat wrote:

> As far as I can tell, this should work as I can't currently imagine why
> a fs operation might end up binding a unix socket despite the idea to
> make af_unix.c yet more complicated in order to work around irregular
> behaviour of (as far as I can tell) a single filesystem (for which
> kern_path_create doesn't really mean kern_path_create

Bullshit.  kern_path_create() *does* mean the same thing in all cases.
Namely, find the parent, lock it and leave the final name component for
the create-type operation.  It sure as hell is not guaranteed to take
*all* locks that are going to be taken in process of mknod/mkdir/etc.
Never had been.

 and it has to work
> around that once it gets control) goes against all instincts I have in
> this area. If filesystems need to do arbitrary stuff when
> __sb_start_write is called for 'their' superblock, they should be able
> to do so directly.
> 
> At present, this is a theoretic concern as I can't (due to other work
> committments) put any non-cursory work into this before Sunday. There
> may also be other reasons why this idea is impractical or even
> unworkable.
