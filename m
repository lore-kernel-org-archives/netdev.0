From: Kyle Hubert <khubert@gmail.com>
Subject: Re: SW csum errors
Date: Wed, 16 Oct 2013 11:58:01 -0400
Message-ID: <CAJoZ4U2C0Ngbd9-zvh+2RzSk4EO_sC6ESFbYx022uoJwj-1iKg@mail.gmail.com>
References: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
	<20131014135859.74f38507@nehalam.linuxnetplumber.net>
	<CAJoZ4U0PNtk2e_x4D3N_fFN32uTVe6Z+FPg7ofG69KjQzsZ7xA@mail.gmail.com>
	<1381937065.2045.131.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:55409 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab3JPP6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:58:03 -0400
Received: by mail-qa0-f47.google.com with SMTP id k15so4401078qaq.20
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 08:58:01 -0700 (PDT)
In-Reply-To: <1381937065.2045.131.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 11:24 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-10-16 at 11:10 -0400, Kyle Hubert wrote:
>
>> Thanks, I didn't realize it was as simple as file backed pages being
>> changed. Yes, our device does support SG, so we do have zero-copy
>> sendfile() support. I'll concoct a simple test to prove this.
>
> You also can use vmsplice()/splice() and touch anonymous memory,
> no need to play with a file ;)

Thanks, this would be even easier to test. It also reminds me that
there are other vectors to constructing SKB frags. It looks like if we
need to enable SW checksumming ever again, we should just disable the
SG feature and let the normal stack handle validity.

-Kyle
