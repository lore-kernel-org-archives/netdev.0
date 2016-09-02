From: CAI Qian <caiqian@redhat.com>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 10:43:20 -0400 (EDT)
Message-ID: <1891948343.1299163.1472827400124.JavaMail.zimbra@redhat.com>
References: <CA+55aFy0cQq569m=0umnqZe6HJp8eQX2ed-yi=Fmntuhd2AM=Q@mail.gmail.com> <6f7d587b-3933-7c02-a804-db1732ced1cf@stressinduktion.org> <CA+55aFyNJg_brA4rGF0S2ve0V_2vuhZCFKEMFDNhHKEXoVCRGA@mail.gmail.com> <20160901204746.GR2356@ZenIV.linux.org.uk> <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com> <20160901210142.GS2356@ZenIV.linux.org.uk> <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com> <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Rainer Weikusat <rweikusat@cyberadapt.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:55980 "EHLO
        mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753364AbcIBOnj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 10:43:39 -0400
In-Reply-To: <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Linus Torvalds" <torvalds@linux-foundation.org>
> To: "Al Viro" <viro@zeniv.linux.org.uk>, "CAI Qian" <caiqian@redhat.com>
> Cc: "Miklos Szeredi" <miklos@szeredi.hu>, "Rainer Weikusat" <rweikusat@cyberadapt.com>, "Hannes Frederic Sowa"
> <hannes@stressinduktion.org>, "Rainer Weikusat" <rweikusat@mobileactivedefense.com>, "Eric Sandeen"
> <esandeen@redhat.com>, "Network Development" <netdev@vger.kernel.org>
> Sent: Thursday, September 1, 2016 6:04:38 PM
> Subject: Re: possible circular locking dependency detected
> 
> On Thu, Sep 1, 2016 at 2:43 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> > On Thu, Sep 1, 2016 at 2:01 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >>
> >> Outside as in "all fs activity in bind happens under it".  Along with
> >> assignment to ->u.addr, etc.  IOW, make it the outermost lock there.
> >
> > Hah, yes. I misunderstood you.
> >
> > Yes. In fact that fixes the problem I mentioned, rather than introducing
> > it.
> 
> So the easiest approach would seem to be to revert commit c845acb324aa
> ("af_unix: Fix splice-bind deadlock"), and then apply the lock split.
> 
> Like the attached two patches.
> 
> This is still *entirely* untested.
Tested-by: CAI Qian <caiqian@redhat.com>
> 
> Rainer?
> 
>                  Linus
> 
