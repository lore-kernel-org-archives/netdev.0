From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [RFC PATCH] Fix false positives in can_checksum_protocol()
Date: Mon, 28 Sep 2015 18:38:52 -0700
Message-ID: <CAEuXFEzmnLJGTx2n89DWVeOd37=w4=zC8BX8E=ikr6s0N=ZWVQ@mail.gmail.com>
References: <1443185758.4674.44.camel@infradead.org>
	<CALx6S34Bs8pOyGXEOvABdG16wyWZuhsg5G4sO_vJgCnz0xxi5A@mail.gmail.com>
	<1443464822.4674.109.camel@infradead.org>
	<CALx6S35VXGfCeYtXm9z2APgt=kAwR2qJ5v7psN+Pg17LcDKasw@mail.gmail.com>
	<1443468381.4674.115.camel@infradead.org>
	<CALx6S354aBCxosvvBFUFSparq981rPf-vAunwdKtUKZLNBxFmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Woodhouse <dwmw2@infradead.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36077 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311AbbI2Bix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 21:38:53 -0400
Received: by ioii196 with SMTP id i196so196353897ioi.3
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 18:38:53 -0700 (PDT)
In-Reply-To: <CALx6S354aBCxosvvBFUFSparq981rPf-vAunwdKtUKZLNBxFmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 12:37 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Sep 28, 2015 at 12:26 PM, David Woodhouse <dwmw2@infradead.org> wrote:
>> On Mon, 2015-09-28 at 12:13 -0700, Tom Herbert wrote:
>>>
>>> > Perhaps a better solution would be a bit in the skbuff which indicates
>>> > that it *is* a TCP or UDP checksum. That would be set by our UDP and
>>> > TCP sockets, cleared by encapsulation, also set if appropriate by
>>> > skb_partial_csum_set().

I've been pondering a bit of a redesign in this space.  I think the
skb struct should be
explicit in its instructions to hardware for which offloads to do for
each packet.

In this way, the stack would be *directly* telling the drivers what to
do (and what not
to do), solving all sorts of bugs and really improving driver
reliability and implementation.

These other solutions you guys are discussing are half solving the
problem, only to
make it worse when the next thing comes along.  Unfortunately it is only an
idea right now and no patches.
