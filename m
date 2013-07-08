From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH iproute2] ipbatch: fix use of 'ip netns exec'
Date: Mon, 8 Jul 2013 14:57:19 +0100
Message-ID: <1373291839.3428.81.camel@deadeye.wl.decadent.org.uk>
References: <1373040345-11116-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1373057353.1913.55.camel@bwh-desktop.uk.level5networks.com>
	 <51DA893C.8070002@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>,
	<junwei.zhang@6wind.com>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20574 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab3GHN5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 09:57:23 -0400
In-Reply-To: <51DA893C.8070002@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-08 at 11:41 +0200, Nicolas Dichtel wrote:
> Le 05/07/2013 22:49, Ben Hutchings a =C3=A9crit :
> > On Fri, 2013-07-05 at 18:05 +0200, Nicolas Dichtel wrote:
> >> From: JunweiZhang <junwei.zhang@6wind.com>
> >>
> >> execvp() does not return when the command succeed, hence all comma=
nds in the
> >> batch file after the line 'ip netns exec' are not executed.
> >>
> >> Let's fork before calling execvp().
> >
> > A Unix shell forks every command it runs, so why should ip do this =
too?
> Just to show the problem:
>=20
> $ cat test.batch
> netns add netns1
> netns exec netns1 ip l
> netns
> $ ip -b test.batch
[...]

Sorry, I totally missed that there is this 'batch' sub-command in ip.  =
I
think you are right that it should fork in this case.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
