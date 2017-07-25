From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: SELinux/IP_PASSSEC regression in 4.13-rcX
Date: Tue, 25 Jul 2017 11:59:38 +0200
Message-ID: <1500976778.2929.5.camel@redhat.com>
References: <CAHC9VhS9QO8jGBodsSeQxxbgoxrmThRgbc3_m17h7gFmfP=GGw@mail.gmail.com>
         <1500899117.2458.2.camel@redhat.com>
         <CAHC9VhRjju-_3V21x+BogdRg-brDho1g_HzW+0CvU0PbhEtQqw@mail.gmail.com>
         <1500912555.2458.12.camel@redhat.com>
         <CAHC9VhSAifQtx3eaQD42XMx8beC08JBGQ9SaKFvkD9qVsT8VCg@mail.gmail.com>
         <CAHC9VhQC1Bpm9VdE2sBC4VLmnzu_B7kLEkgBtnDKvwKf5w1HyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750793AbdGYJ7k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 05:59:40 -0400
In-Reply-To: <CAHC9VhQC1Bpm9VdE2sBC4VLmnzu_B7kLEkgBtnDKvwKf5w1HyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-24 at 22:00 -0400, Paul Moore wrote:
> > I'm happy to test this, but if you are curious, you can find the
> > selinux-testsuite at the link below; the "inet_socket" tests are the
> > ones relevant to this problem.
> > 
> > * https://github.com/SELinuxProject/selinux-testsuite

Thanks, I'll have a look.

> > However, I believe there is a problem with this patch, see below.

[...]

> > > -#if BITS_PER_LONG == 64
> > > +#define UDP_SKB_IS_STATELESS 0x80000000
> > > +
> > >  static void udp_set_dev_scratch(struct sk_buff *skb)
> > >  {
> > > -       struct udp_dev_scratch *scratch;
> > > +       struct udp_dev_scratch *scratch = udp_skb_scratch(skb);
> > > 
> > >         BUILD_BUG_ON(sizeof(struct udp_dev_scratch) > sizeof(long));
> > 
> > The BUILD_BUG_ON() assertion no longer appears to be correct with this patch.
> 
> Nevermind, I just took a closer look at this and realized I made a
> mistake when applying your patch (had to apply manually for some
> reason).  I'm building a test kernel now.

Yup, I compile-tested the code, plus some basic sanity checks, so the
build breakage felt unexpected.

Thanks for testing,

Paolo
