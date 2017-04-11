From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: RFC: Checksum offload and XDP
Date: Tue, 11 Apr 2017 11:43:24 -0700
Message-ID: <20170411114324.3fd8d9ba@cakuba.lan>
References: <CALx6S357=e3414sPBnW3ajzXfkvVBiGMChx+vgbf9snpe95-aQ@mail.gmail.com>
        <63f0f671-5b33-4895-355c-be6259b16341@solarflare.com>
        <CALx6S347tj_nA0i4naN9SWaGVm27SPid3c=_KJcfQnsYAuqxSA@mail.gmail.com>
        <21cd2caf-56a8-a330-1260-a55ddf07d854@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "Alexei Starovoitov" <ast@kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:37568 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751997AbdDKSnq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 14:43:46 -0400
In-Reply-To: <21cd2caf-56a8-a330-1260-a55ddf07d854@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Apr 2017 18:13:37 +0100, Edward Cree wrote:
> > Note that this only applies to
> > checksum_complete, if we were to allow XDP program to return
> > checksum_unnecessary for instance then it's more a leap of faith that
> > things are always correct.  
> Speaking of checksum_unnecessary, it might still be useful for the
>  verifier to tell us whether the program contains any writes, since if
>  so any drivers using checksum_unnecessary will have to clear it when
>  calling XDP or else do conversion to checksum_complete beforehand.

If we exposed csum_complete as a value in xdp buffer, we could make the
unnecessary -> complete conversion dependent on accesses to that field
rather than writes and header adjustments.  If program doesn't read or
write the csum it doesn't care about the csum.

And make invalidation of unnecessary dependent on writes and header
adjustments.
