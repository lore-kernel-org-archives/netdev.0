From: Timo Teras <timo.teras@iki.fi>
Subject: Re: GRE+XFRM+GSO crashes
Date: Wed, 22 May 2013 14:09:48 +0300
Message-ID: <20130522140948.3e3ad94e@vostro>
References: <20130520094127.546a2f3e@vostro>
	<CALnjE+qgOQUDm_gAuygpDE5VH23YS0i3QyQuCVPhgu15=jwXWw@mail.gmail.com>
	<20130521110132.37dc2665@vostro>
	<CALnjE+qOf2pxzP0-7s4AsSNDbG5M5s8bXFDqYoD-5NgmtKYixA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:64117 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab3EVLIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:08:14 -0400
Received: by mail-ea0-f180.google.com with SMTP id g10so1039625eak.39
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 04:08:12 -0700 (PDT)
In-Reply-To: <CALnjE+qOf2pxzP0-7s4AsSNDbG5M5s8bXFDqYoD-5NgmtKYixA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 May 2013 15:32:35 -0700
Pravin Shelar <pshelar@nicira.com> wrote:

> On Tue, May 21, 2013 at 1:01 AM, Timo Teras <timo.teras@iki.fi> wrote:
> > On Mon, 20 May 2013 10:58:03 -0700
> > Pravin Shelar <pshelar@nicira.com> wrote:
> >
> >> On Sun, May 19, 2013 at 11:41 PM, Timo Teras <timo.teras@iki.fi>
> >> wrote:
> >> > Since upgrade from 3.8 to 3.9 I've started getting the below
> >> > mentioned BUG crashes. One of the few relevant changes seems to
> >> > be GSO support in GRE driver.
> >> >
> >> > Turning off SG (and GSO) seems to make these crashes disappear.
> >> >
> >> > The basic setup is:
> >> > - gre1 is an NBMA tunnel (no explicit destination, nor bound
> >> >   target interface; opennhrp daemon creates neigh mappings)
> >> > - IPsec policy to encrypt all GRE traffic in transport mode
> >> > - VIA Padlock hardware for AES acceleration
> >> > - GRE traffic goes to r8169 NIC; rx on, gro on, tx off, sg off,
> >> > gso off
> >> >
> >> > Incidentally, when I tried exact same setup ran as virtualized, I
> >> > was unable to reproduce this crash. I suspect it depends on the
> >> > target NIC acceleration capabilities.
> >> >
> >> I do not have access to this hardware, can you tell me what are
> >> target device capabilities?
> >
> > The physical hardware from which the OOPS is from:
> >[snip]
> 
> OK. I am still not able to reproduce it, Can you try attached patch?
> if that works, I will send out proper patch.

No. Seems this is not GSO related at all, after all. I was unable to
reliably reproduce this oops originally and for some weird reason it
happened only with GSO and this specific hardware. I finally
pinpointed a way to trigger this reliably, and it does happen without
GSO too.

I'm pretty sure I've pinpointed the commit breaking things, and have a
fix already building. Will post it after testing.

Thanks for the help anyways.
