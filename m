From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 18:53:48 +0100
Message-ID: <20160902175347.GW2356@ZenIV.linux.org.uk>
References: <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com>
 <20160901210142.GS2356@ZenIV.linux.org.uk>
 <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com>
 <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
 <87lgzae3f7.fsf@doppelsaurus.mobileactivedefense.com>
 <20160902160026.GT2356@ZenIV.linux.org.uk>
 <87d1kme10a.fsf@doppelsaurus.mobileactivedefense.com>
 <20160902170256.GU2356@ZenIV.linux.org.uk>
 <CA+55aFz-TaU=C47Rna4b_pibKPfabXWtt88gaqWkUdcN9ay9nQ@mail.gmail.com>
 <8737lib3o4.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        CAI Qian <caiqian@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Rainer Weikusat <rweikusat@cyberadapt.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59450 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbcIBRxx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:53:53 -0400
Content-Disposition: inline
In-Reply-To: <8737lib3o4.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2016 at 06:40:59PM +0100, Rainer Weikusat wrote:

> The original deadlock occurred because of some code path locking the
> superblock followed by trying to acquire the af_unix readlock while

Not even that - one code path takes ->readlock under pipe lock, while
another takes pipe lock under sb_start_write...
