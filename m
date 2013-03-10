From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next.git 2/9] stmmac: add IEEE 1588-2002 PTP support
Date: Sun, 10 Mar 2013 13:31:54 +0100
Message-ID: <20130310123154.GB6407@netboy.at.omicron.at>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
 <1362653419-1047-3-git-send-email-peppe.cavallaro@st.com>
 <20130308063437.GB2382@netboy.at.omicron.at>
 <51398CFD.9010605@st.com>
 <CAJ3bTp6tQ4L0vya9-eO0E+19Wk74uNJonbA9hqc+fgN77dcjOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, bh74.an@samsung.com
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:41642 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab3CJMcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 08:32:07 -0400
Received: by mail-ee0-f52.google.com with SMTP id b15so1719344eek.39
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 05:32:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3bTp6tQ4L0vya9-eO0E+19Wk74uNJonbA9hqc+fgN77dcjOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 01:15:00PM +0530, Rayagond K wrote:
> On Fri, Mar 8, 2013 at 12:32 PM, Giuseppe CAVALLARO <peppe.cavallaro@=
st.com>wrote:
> > On 3/8/2013 7:34 AM, Richard Cochran wrote:

> >> What are these coarse/fine method? Can't we always use the fine on=
e?
> >>
> >
> > This is explained in the "4.1.2 System Time Register Module" of Syn=
opsys
> > Databook. Summarizing, the MAC can have an optional module and use =
this
> > coarse correction method. In the fine correction method, a slave cl=
ock=E2=80=99s
> > frequency drift with respect to the master clock is corrected over =
a period
> > of time instead of in one clock, as in coarse correction.
> >
> > Pls, Rayagond feels free to provide more details...
>=20
>=20
> Yes Synopsys core support two method for correcting the system time
> ie COARSE method  and FINE method.
>=20
> In the fine correction method, a slave clock=E2=80=99s frequency drif=
t with respect
> to the master clock (as defined in IEEE 1588) is corrected over a per=
iod of
> time instead of in one clock, as in coarse correction. This helps mai=
ntain
> linear time and does not introduce drastic changes (or a large jitter=
) in
> the reference time between PTP Sync message intervals.

So it sounds like to me that you only should offer the COARSE
method. Smoothly changing the frequency of the clock is the job of the
clock servo which is running in user space.

Although some clocks (like this one and the phyter, for example) have
the ability to smoothly correct a given offset over a given time, we
do not have any user/kernel API for making use of this feature.

Thanks,
Richard
