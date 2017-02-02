From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Thu, 02 Feb 2017 10:56:23 -0800
Message-ID: <1486061783.21871.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486031855-10551-1-git-send-email-simon.horman@netronome.com>
         <1486031855-10551-2-git-send-email-simon.horman@netronome.com>
         <1486038693.13103.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170202155849.GA28482@penelope.horms.nl>
         <CALx6S37b00GfUBQ5imVfOhg2Rbp_GtDntkwqyj3cN8kzt6gG0w@mail.gmail.com>
         <20170202174803.GF1845@nanopsycho.orion>
         <CALx6S37QtKgc14DFway-Ajme7JhbAN71M+83w28+4FELdv7Xew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34660 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdBBS4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:56:25 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so2041520pfb.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 10:56:25 -0800 (PST)
In-Reply-To: <CALx6S37QtKgc14DFway-Ajme7JhbAN71M+83w28+4FELdv7Xew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-02 at 10:36 -0800, Tom Herbert wrote:

> It's going to be a problem with a whole host of application level
> protocols especially those run over UDP. QUIC is a great example. The
> actual protocol will probably only ever run in userspace, but it is
> inevitable that we want to provide targeted kernel support for packet
> steering. filtering, GRO/GSO if they have such things. Instead of
> implementing this in a specialized QUIC module, it will most likely
> make everyone happier to add these in a generic protocol-agnostic way.
> From QUIC POV they want to minimize any dependencies on the kernel and
> be able to iterate quickly, from a kernel POV we really don't want to
> have to explicitly support an endless stream of protocols like this.

Small note here : Google does not intend to add QUIC knowledge anywhere
in the kernel.

SO_ATTACH_REUSEPORT_EBPF can be used if someone wants to take a deep
look at QUIC header (and presumably hash the connection-id) to select
one socket among the group.

Thanks.

 
