From: San Mehat <san@google.com>
Subject: Re: [RFC 0/0] Introducing a generic socket offload framework
Date: Fri, 19 Aug 2011 07:58:29 -0700
Message-ID: <CAPi7mHp==JPA-0vNZ+xWRzOuJYUxsUL3UY=o=VtMUsB-YcFHwQ@mail.gmail.com>
References: <20110818220756.5C93E5C80B@san.sea.corp.google.com>
	<1313758185.16299.43.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mst@redhat.com, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	digitaleric@google.com, mikew@google.com, miche@google.com,
	maccarro@google.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:28731 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab1HSO6b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:58:31 -0400
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p7JEwVHq015868
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:58:31 -0700
Received: from gyd12 (gyd12.prod.google.com [10.243.49.204])
	by wpaz9.hot.corp.google.com with ESMTP id p7JEwTmv022636
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:58:30 -0700
Received: by gyd12 with SMTP id 12so2545178gyd.32
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 07:58:29 -0700 (PDT)
In-Reply-To: <1313758185.16299.43.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 5:49 AM, jamal <hadi@cyberus.ca> wrote:
>
> On Thu, 2011-08-18 at 15:07 -0700, San Mehat wrote:
> > TL;DR
> > -----
> > In this RFC we propose the introduction of the concept of hardware =
socket
> > offload to the Linux kernel. Patches will accompany this RFC in a f=
ew days,
> > but we felt we had enough on the design to solicit constructive dis=
cussion
> > from the community at-large.
> >
>
> [..]
>
> > ALTERNATIVE STRATEGIES
> > ----------------------
> >
> > An alternative strategy for providing similar functionality involve=
s either
> > modifying glibc or using LD_PRELOAD tricks to intercept socket call=
s. We were
> > forced to rule this out due to the complexity (and fragility) invol=
ved with
> > attempting to maintain a general solution compatible across various
> > distributions where platform-libraries differ.
>
> Above should have been in your TL;DR;->
>
> LD_PRELOAD is also horrible because of the granularity of the socket
> calls;
> Having things in the kernel and specifically tagging socket as needin=
g
> this feature is much much more manageable.
>
> Tying things to virtualization may miss the big picture because there
> are many other use cases for intercepting socket calls, example:
> Samir Bellabes <sam@synack.fr> has been trying to get what he refers =
to
> as "personal firewall" (equivalent to the silly windows firewall) whi=
ch
> prompts the user "ping from blah, do you want to allow a response?"
> That requires intercepting send/recv calls, prompt the user in possib=
ly
> some pop-up and act based on response. It requires looking at content=
=2E
> He is trying to use selinux for that interface,
> but i think this would be the right abstraction.

I agree; there's no reason this needs to be tied to virtualization -
it was just the
driving force behind the design. I will generalize the backend interfac=
e types

> I hope you plan to support send/recv.

yes

> I also hope you add support for SOCK_RAW (and maybe SOCK_PACKET).

Can you explain a good use-case for SOCK_RAW in this type of
environment? We were noodling it around locally and couldn't come up
with one that we needed to support.

>
> Q: If you want this to be transparent to the apps, who/what is doing
> the tagging of SOCK_HWASSIST? clearly not the app if you dont want to
> change it.

The decision of whether to tag a socket or not is made by the 'hardware=
'

>
> I like the uri abstraction if it doesnt come at the expense of the
> app transparency.
>

Thank you

-san

> cheers,
> jamal
>



--
San Mehat=A0|=A0Staff Software Engineer=A0|=A0san@google.com=A0|=A0415-=
366-6172
