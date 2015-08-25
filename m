From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: asconf process should treat multiple address
 parameter as unrecognized parameter
Date: Tue, 25 Aug 2015 11:18:59 -0300
Message-ID: <20150825141859.GE1873@localhost.localdomain>
References: <13ab95079875febb3985b32d0fdaf587c6de1973.1440410850.git.lucien.xin@gmail.com>
 <55DB5939.8030902@redhat.com>
 <CADvbK_c0=B5A66gqMRAg1x7iqUb7NFzs5roNW6fxHzexXovT6g@mail.gmail.com>
 <CADvbK_cM2u452XWWdHggrCu7f+_v80Ucb3XMAJqeqCjBjwQjJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevic@redhat.com, network dev <netdev@vger.kernel.org>,
	davem <davem@davemloft.net>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755927AbbHYOTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 10:19:01 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_cM2u452XWWdHggrCu7f+_v80Ucb3XMAJqeqCjBjwQjJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 08:43:10PM +0800, lucien xin wrote:
> On Tue, Aug 25, 2015 at 8:39 PM, lucien xin <lucien.xin@gmail.com> wrote:
> >>
> >> I think it would be much better to catch this in the validation stage.
> >> If an implementation inserts multiple address parameters, we don't really know
> >> which one we should be using.
> >>
> >
> > the params of ASCONF chunk should consist of one *Address Parameter* and one
> > or more *ASCONF Parameters*. besides, the address parameter should be in the
> > beginning. so the first one must be our choice.

That's not necessarily true. You're assuming the first is the best but
that's not ensured anywhere as RFC doesn't allow multiple parameteres in
there.

That also puts the entire asconf in question, because if it needed an
address parameter and now it has many and you don't know which one you
should use, you actually have none, and the needed parameter is thus
missing.

> > if we cat this in the validation stage, I think it will be hard to treat it as a
> > unrecognized parameter,
> because *unrecognized parameter* cause packet need to be built in
> sctp_process_asconf(),
> as current linux's implementation.

I agree with Vlad, but yeah, it may make error reporting harder.
Although I don't have any issue if we just fall through the current error
handling for bad asconf chunks, which aborts the association due to
param len violation. Vlad?

  Marcelo
