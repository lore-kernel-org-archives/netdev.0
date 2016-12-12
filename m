From: Brandon Philips <brandon.philips@coreos.com>
Subject: Re: fib_frontend: Add network specific broadcasts, when it takes a sense
Date: Mon, 12 Dec 2016 09:44:54 -0500
Message-ID: <CAD2oYtPPsvHgitejXTMAYa8qVvkibdPruEUcv8hhhiCfgfOvvw@mail.gmail.com>
References: <CAD2oYtOS3YKFhhAfXSdJUjKyAx9JpfGz-JLNvGC_mYP7zRp+Rg@mail.gmail.com>
 <20161212153035.4a751ccc@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Tom Denham <tom@tigera.io>,
        Aaron Levy <aaron.levy@coreos.com>,
        Brad Ison <bison@coreos.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35933 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbcLLOo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 09:44:56 -0500
Received: by mail-qt0-f174.google.com with SMTP id w33so77404413qtc.3
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 06:44:55 -0800 (PST)
In-Reply-To: <20161212153035.4a751ccc@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 9:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 9 Dec 2016 15:41:52 -0800, Brandon Philips wrote:
>> The issue we have: when creating the VXLAN interface and assigning it
>> an address we see a broadcast route being added by the Kernel. For
>> example if we have 10.4.0.0/16 a broadcast route to 10.4.0.0 is
>> created. This route is unwanted because we assign 10.4.0.0 to one of
>> our VXLAN interfaces.
>
> Are you saying you're trying to assign the IP address 10.4.0.0/16 as a
> unicast address to an interface? Then you'll run into way more problems
> than the one you're describing. You can't have host part of the IP
> address consisting of all zeros (or all ones). Just don't do it. Choose
> a valid IP address instead.

Yes, this is what we are doing; it is because of an upstream, to us,
address assignment so I will figure it out upstream.

Regardless, it is hard to find an RFC that says "simply don't do this
because _____". The closest I could find was RFC 922 after sending
this which says:

"There is probably no reason for such addresses to appear anywhere but
as the source address of an ICMP Information".

I will submit a patch that at least documents this RFC and quote.

Thanks!

Brandon
