From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 15:00:34 -0800
Message-ID: <CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
	<20160129210900.GD17127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Dalton <mwdalton@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36197 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbcA2XAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 18:00:34 -0500
Received: by mail-ig0-f180.google.com with SMTP id z14so47323462igp.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 15:00:34 -0800 (PST)
In-Reply-To: <20160129210900.GD17127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 1:09 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/29/16 13:00), Tom Herbert wrote:
>> Doesn't every IP/VXLAN packet contains unaligned headers? Why don't
>> those create alignment issues (like when stack looks at addresses)?
>
> They do.
>
> http://comments.gmane.org/gmane.linux.network/370672
>
> some of it was fixed in https://lkml.org/lkml/2015/7/20/63.
> There's still some NET_IP_ALIGN missing. IIRC, I was seeing
> this for mldv3, but the fix has to be done carefully, by
> someone who knows how to fully regression test it.
>
> I dont know if other tunneling methods manage to get the
> NET_IP_ALIGN correct in every case.
>
> Also, while sparc complains about unaligned access
> in most cases, some sins may pass under the radar, and other
> platforms dont even generate traps, so it's easy to not know
> that there's a problem, a lot of the time.
>
The sparc documentation is pretty clear
http://docs.oracle.com/cd/E19253-01/816-4854/hwovr-2/index.html, seems
like unaligned accesses are not allowed in the architecture.

Tom

> --Sowmini
>
