From: Jesper Derehag <jderehag@hotmail.com>
Subject: RE: [PATCH 1/1] connector: Added coredumping event to the process
 connector
Date: Sat, 16 Mar 2013 19:08:03 +0000
Message-ID: <DUB002-W14207698E8638F6DEB6F4A7DDEE0@phx.gbl>
References: <20130316170348.GD24041@order.stressinduktion.org>
 <DUB002-W54999962E08C0F2E11B4EEDDEE0@phx.gbl>,<20130316184036.GE24041@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s21.dub0.hotmail.com ([157.55.0.220]:46949 "EHLO
	dub0-omc1-s21.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751092Ab3CPTOS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Mar 2013 15:14:18 -0400
In-Reply-To: <20130316184036.GE24041@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----------------------------------------
> Date: Sat, 16 Mar 2013 19:40:36 +0100
> From: hannes@stressinduktion.org
> To: jderehag@hotmail.com
> CC: zbr@ioremap.net; netdev@vger.kernel.org
> Subject: Re: [PATCH 1/1] connector: Added coredumping event to the pr=
ocess connector
>
> On Sat, Mar 16, 2013 at 05:57:20PM +0000, Jesper Derehag wrote:
> >
> >
> > > Date: Sat, 16 Mar 2013 18:03:48 +0100
> > > From: hannes@stressinduktion.org
> > > To: jderehag@hotmail.com
> > > CC: zbr@ioremap.net; netdev@vger.kernel.org
> > > Subject: Re: [PATCH 1/1] connector: Added coredumping event to th=
e process connector
> > >
> > > On Sat, Mar 16, 2013 at 11:50:50AM +0100, Jesper Derehag wrote:
> > > > + ev->event_data.exit.exit_code =3D task->exit_code;
> > > > + ev->event_data.exit.exit_signal =3D task->exit_signal;
> > >
> > > Do these already contain meaningful values?
> > >
> >
> > I have to admit that they dont.And you are correct, I should add a =
new event struct specific for the coredump event instead of piggybackin=
g on the exit struct.Will re-submit a patch..
>
> Hm, I am still unsure if such a patch is needed. Couldn't you test fo=
r
> coredump by inspecting exit_code on PROC_EVENT_EXIT?

*** resubmitted message due to it got dropped by vger.kernel.org ***

=A0Well, what this patch adds I think is more a question of timing.=A0
=A0As an example, say you want to quickly detect process failures. In t=
hat=A0case if we would only have the EXIT event, that would mean that w=
e get=A0notified after the dump is done, which could take minutes depen=
ding on=A0how large the dump is.=A0
If we instead watch for both EXIT & COREDUMP=A0events, it would mean th=
at we would quickly catch any failing process,=A0regardless of if its a=
ctually starting to coredump or if its exited for=A0some other reason. =
		 	   		  