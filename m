From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 1/2] net: Add Transparent Ethernet Bridging GRO support.
Date: Wed, 31 Dec 2014 09:30:31 -0500
Message-ID: <CAEP_g=92m9KFcMoViZ5vvBOjypta-NC2qJ1huqUVBSoXLYVWng@mail.gmail.com>
References: <1419995416-29987-1-git-send-email-jesse@nicira.com> <CAJ3xEMhSJN5yNm69Hfpe3L9kv0kDx=hSABkD_NPz2dsQDt3Xnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:39110 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751237AbaLaOax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 09:30:53 -0500
Received: by mail-qa0-f50.google.com with SMTP id dc16so11116509qab.37
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 06:30:52 -0800 (PST)
In-Reply-To: <CAJ3xEMhSJN5yNm69Hfpe3L9kv0kDx=hSABkD_NPz2dsQDt3Xnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 4:19 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Wed, Dec 31, 2014 at 5:10 AM, Jesse Gross <jesse@nicira.com> wrote:
>> Currently the only tunnel protocol that supports GRO with encapsulated
>> Ethernet is VXLAN. This pulls out the Ethernet code into a proper layer
>> so that it can be used by other tunnel protocols such as GRE and Geneve.
>
> Hi Jesse,
>
> Thanks for taking care of that, I also had it coded under the
> intention of adding GRO support for OVS's TEB based GRE, but didn't
> make it to submit before your post... anyway, I would recommend that
> you break this patch into two:
>
> 1. basic TEB GRO support
> 2. refactoring of the VXLAN GRO logic to use it

This patch is really just moving code so breaking it into two steps
would essentially mean introducing duplicate code and then deleting
the first version in the next patch. It's already a pretty short patch
and I think splitting it would actually make it harder to verify that
it is correct.
