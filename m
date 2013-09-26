From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2] net: qmi_wwan: fix checkpatch warnings
Date: Thu, 26 Sep 2013 12:41:48 +0200
Message-ID: <87y56jn9ub.fsf@nemi.mork.no>
References: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com>
	<1380100886-16531-2-git-send-email-fabio.porcedda@gmail.com>
	<877ge5own8.fsf@nemi.mork.no>
	<CAHkwnC-05BdptYjw0H+k=tc5fXq1Tc5pJyDQLGEvUZA5fy2NHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dan Williams <dcbw@redhat.com>
To: Fabio Porcedda <fabio.porcedda@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38384 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687Ab3IZKmB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 06:42:01 -0400
In-Reply-To: <CAHkwnC-05BdptYjw0H+k=tc5fXq1Tc5pJyDQLGEvUZA5fy2NHQ@mail.gmail.com>
	(Fabio Porcedda's message of "Thu, 26 Sep 2013 11:06:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46abio Porcedda <fabio.porcedda@gmail.com> writes:

> Hi Bj=C3=B8rn,
> thanks for reviewing.
>
> On Wed, Sep 25, 2013 at 3:31 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>> Sorry, I really don't see the point of this.  Yes, the lines are lon=
ger
>> than 80 columns, but breaking them don't improve the readability at
>> all.  On the contrary, IMHO.
>>
>> So NAK from me for this part.
>
> Which changes do you think do not improve the readability?

Anything that breaks a previously unbroken argument list will reduce th=
e
readability in my opinion.  The lines can of course not be unlimited,
but there is no need to set the limit as low as 80 columns.  Feedback
I've got from developers using e.g. 80 column braille devices is that
longer lines isn't really a problem for them either.

The point is that the properly broken lines aren't that much more
readable than a line broken by your terminal, even if you set it to 80
columns.  You do of course not get the proper indendation of the broken
lines, but you get a terminal hint telling you that it is a continuatio=
n
line.  Which is often better that having to figure it out based on the
code.

This isn't to say that I don't think writing shorter lines is a goal.
I'd really like the code to be nice and compact, avoiding this
discussion completely by just keeping every line shorter than 80.  But
I'm just not that good a programmer :-)

I'd surely appreciate any patch moving the code in that direction.

> I'm sure that at least some of them actually improve the readability.

Yes, reformatting the comments improves the readability.  I just don't
think that makes any sense on it's own, if the surrounding lines are
kept longer.

If the code can be rewritten to actually *be* shorter than 80 columns
instead of just breaking too long code lines, then that is a definite
improvement.  You didn't have many examples of this, I believe.  But
reducing the indent level, removing unnecessary function parameters, or
splitting declaration and initialization are changes which often reduce
the line length while improving the readability at the same time.
Breaking lines rarely do.

This is the only one of your code changes which I can be convinced to
agreeing may improve readability:

-     if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) || (!on=
 && atomic_dec_and_test(&info->pmcount))) {
+     if ((on && atomic_add_return(1, &info->pmcount) =3D=3D 1) ||
+         (!on && atomic_dec_and_test(&info->pmcount))) {


But it mostly points out a piece of code which is too complex in the
first place, begging to be rewritten in a more elegant form.

Just for the record:  All this is of course only my personal opinions,
and I am fine with being overridden even if I originally wrote the ugly
code :-)

David decides.


Bj=C3=B8rn
