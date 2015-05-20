From: Cong Wang <cwang@twopensource.com>
Subject: Re: ingress policying for realtime protocol
Date: Wed, 20 May 2015 16:46:54 -0700
Message-ID: <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
References: <20150519211145.GA23134@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35431 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbbETXq4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:46:56 -0400
Received: by wicmx19 with SMTP id mx19so171797923wic.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 16:46:55 -0700 (PDT)
In-Reply-To: <20150519211145.GA23134@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Cc'ing Jamal)

On Tue, May 19, 2015 at 2:11 PM, Uwe Kleine-K=C3=B6nig
<u.kleine-koenig@pengutronix.de> wrote:
> Hello,
>
> I hope this is the/a right list to ask this question. If not, I'd be
> happy to learn the right alternative.
>
> For a system that implements the Media Redundancy Protocol (MRP,
> http://en.wikipedia.org/wiki/Media_Redundancy_Protocol) I'm faced wit=
h
> the task to assert that the corresponding ethernet packets are handle=
d
> "in time". Currently this fails already if I do
>
>         scp somebigfile mymrpsystem:
>
> The first idea was to use ingress policying to limit all packets that
> are not related to MRP to a certain rate.
>
> The problem in practise however is that the rate that has to be used
> above is very low (100kbit) so we're looking for alternatives. I wond=
er
> what's missing to get ingress policying more versatile to allow for
> example a prio qdisc or if there is some conceptual problem that I do=
n't
> see. I'm not sure this would solve our problem, but it's definitely
> something I want to play with before trying/resorting to hackish
> solutions (like hacking the eth-driver to pipe MRP packets directly t=
o
> the network userspace application instead of through the network stac=
k).
>

There is very little to do on ingress side since there is no queue at a=
ll,
not to mention priority, you could try ifb to see if it fits your need.
