From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] Fix false positives in can_checksum_protocol()
Date: Mon, 28 Sep 2015 20:04:54 -0700
Message-ID: <CALx6S35f8hWfBktvou9B41EwFoODYZJZyfetOdLmeeLcuMHT9A@mail.gmail.com>
References: <1443185758.4674.44.camel@infradead.org>
	<CALx6S34Bs8pOyGXEOvABdG16wyWZuhsg5G4sO_vJgCnz0xxi5A@mail.gmail.com>
	<1443464822.4674.109.camel@infradead.org>
	<CALx6S35VXGfCeYtXm9z2APgt=kAwR2qJ5v7psN+Pg17LcDKasw@mail.gmail.com>
	<1443468381.4674.115.camel@infradead.org>
	<CALx6S354aBCxosvvBFUFSparq981rPf-vAunwdKtUKZLNBxFmQ@mail.gmail.com>
	<CAEuXFEzmnLJGTx2n89DWVeOd37=w4=zC8BX8E=ikr6s0N=ZWVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Woodhouse <dwmw2@infradead.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33592 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbbI2DEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 23:04:55 -0400
Received: by iofh134 with SMTP id h134so197228986iof.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 20:04:54 -0700 (PDT)
In-Reply-To: <CAEuXFEzmnLJGTx2n89DWVeOd37=w4=zC8BX8E=ikr6s0N=ZWVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 6:38 PM, Jesse Brandeburg
<jesse.brandeburg@gmail.com> wrote:
> On Mon, Sep 28, 2015 at 12:37 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, Sep 28, 2015 at 12:26 PM, David Woodhouse <dwmw2@infradead.org> wrote:
>>> On Mon, 2015-09-28 at 12:13 -0700, Tom Herbert wrote:
>>>>
>>>> > Perhaps a better solution would be a bit in the skbuff which indicates
>>>> > that it *is* a TCP or UDP checksum. That would be set by our UDP and
>>>> > TCP sockets, cleared by encapsulation, also set if appropriate by
>>>> > skb_partial_csum_set().
>
> I've been pondering a bit of a redesign in this space.  I think the
> skb struct should be
> explicit in its instructions to hardware for which offloads to do for
> each packet.
>
> In this way, the stack would be *directly* telling the drivers what to
> do (and what not
> to do), solving all sorts of bugs and really improving driver
> reliability and implementation.
>
Doesn't CHECKSUM_PARTIAL with csum_offset and csum_start already tell
the driver unambiguously what to do wrt checksum offload?

> These other solutions you guys are discussing are half solving the
> problem, only to
> make it worse when the next thing comes along.  Unfortunately it is only an
> idea right now and no patches.
