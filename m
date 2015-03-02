From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in
 sch_sfq
Date: Mon, 02 Mar 2015 12:02:27 -0800
Message-ID: <1425326547.5130.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	 <1425247789-21211-7-git-send-email-therbert@google.com>
	 <1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
	 <CA+mtBx-Bhewd6Ez4OotWEhxvVO8rrOieWCGAnMa9vfhTbzj=yg@mail.gmail.com>
	 <1425324483.5130.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx8sFBV4hFkdnvChuO0UaoN=XHKgVhreM5GwQXXgR9ARvg@mail.gmail.com>
	 <1425325397.5130.117.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx__JSLgiX9MTa-ErR4kATnCxXbVX+6wQvj8fkh8ZD-mtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:44963 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427AbbCBUC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:02:28 -0500
Received: by iecar1 with SMTP id ar1so51045656iec.11
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 12:02:28 -0800 (PST)
In-Reply-To: <CA+mtBx__JSLgiX9MTa-ErR4kATnCxXbVX+6wQvj8fkh8ZD-mtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 11:51 -0800, Tom Herbert wrote:
> On Mon, Mar 2, 2015 at 11:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2015-03-02 at 11:34 -0800, Tom Herbert wrote:
> >
> >> Spraying would be quite easy by modulating txhash from TCP and using
> >> either  UDP encapsulation like GUE or IPv6 flow labels. Only problem
> >> is that this would constantly be changing rxhash at the receiver for
> >> the connection, although flow labels might 'just work' with IPv6
> >> Toeplitz in NICs.
> >
> > When I said 'regular IPv4/tcp traffic' this did not include any added
> > encapsulation.
> >
> > Most NIC are not able to properly offload TCP (TSO) with such
> > encapsulations.
> >
> IPv6 flow labels should work through TSO, they would just be
> replicated for each segment. You would need switches that can hash
> based on flow label though, and of course IPv6 deployed in the network
> :-).


Yeah, but I explicitly talked about native IPv4 + TCP ;)

not IPv6 + TCP, or IPv6 + IPV4 + TCP or some encapsulation...

Trend is to generalize random packet spraying, even within a flow.

https://www.cs.purdue.edu/homes/kompella/publications/infocom13.pdf

This forces us to build a resilient TCP stack.
