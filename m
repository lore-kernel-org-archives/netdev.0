From: Chris Rorvick <chris@rorvick.com>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Wed, 12 Oct 2016 12:50:57 -0500
Message-ID: <CAEUsAPYYJ3Gmh0T16veCn3wnzdD8bTxE+_U-AUYQpMo3TUd4Mg@mail.gmail.com>
References: <20161010071943.4717-1-chris@rorvick.com> <1476108164.5210.11.camel@coelho.fi>
 <1476180668.17022.21.camel@tiscali.nl> <1476252719.7776.6.camel@coelho.fi> <1476255135.1972.5.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>, Luca Coelho <luca@coelho.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33360 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754885AbcJLRvE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 13:51:04 -0400
In-Reply-To: <1476255135.1972.5.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Luca,

FYI, It seems that Google does not like your email as I'm not
receiving any of your messages in gmail.  Some responses below:

On Wed, 2016-10-12 at 15:24 +0300, Luca Coelho wrote:
> Hi Chris,
> On Tue, 2016-10-11 at 09:09 -0500, Chris Rorvick wrote:
> > On Tue, Oct 11, 2016 at 5:11 AM, Paul Bolle <pebolle [at] tiscali> wrot=
e:
> > > > This is not coming from the NIC itself, but from the platform's ACP=
I
> > > > tables. Can you tell us which platform you are using?
> >
> > Interesting. I'm running a Dell XPS 13 9350. I replaced the
> > factory-provided Broadcom card with an AC 8260. I can update the
> > commit log to reflect this.
>
> Okay, so this makes sense. Those entries are probably formatted for
> the Broadcom card, which the iwlwifi driver obviously doesn't
> understand. The best we can do, as I already said, is to ignore values
> we don't understand.

This may already be apparent, but Dell sells two versions of the 9350:
one with the Broadcom adapter and one with the AC 8260.  I just
happened to find the former version at a deep discount at Costco so
decided to chance it.  Turns out the Broadcom card is not so good even
with new kernels so I upgraded.  Anyway, since Paul is seeing the same
issue I don't think the values are intended to be Broadcom-specific.

On Wed, 2016-10-12 at 17:21 +0300, Luca Coelho wrote:
> And, the values in the SPLX structs are being changed here, to DOM1,
> LIM1, TIM1 etc., before being returned. =C3=82 This also matches your
> description that, at runtime, you got something different than the pure
> dump. =C3=82 If you follow these DOM*, LIM*, TIM* symbols, you'll probabl=
y
> end up getting the values you observed at runtime.

Probably not important, but it seems that there is some additional
indirection.  The only values I'm seeing associated with those symbols
are 8 and 16:

    $ grep -e 'DOM[0-9]' -e 'LIM[0-9]' -e 'TIM[0-9]' dsdt.dsl | grep -v Sto=
re
    DOM1,   8,
    LIM1,   16,
    TIM1,   16,
    DOM2,   8,
    LIM2,   16,
    TIM2,   16,
    DOM3,   8,
    LIM3,   16,
    TIM3,   16,

> I'll send you a patch for testing soon.

I will keep an eye on the list archive, thanks!

Chris
