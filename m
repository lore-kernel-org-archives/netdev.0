From: Marc Herbert <marc.herbert@free.fr>
Subject: Re: [RFC] ethtool semantics
Date: Tue, 8 Jun 2004 01:43:26 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406080111550.2832@fcat>
References: <20040607212804.GA17012@k3.hellgate.ch> <20040607145723.41da5783.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Roger Luethi <rl@hellgate.ch>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040607145723.41da5783.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jun 2004, David S. Miller wrote:

> On Mon, 7 Jun 2004 23:28:04 +0200
> Roger Luethi <rl@hellgate.ch> wrote:
>
> > What is the correct response if a user passes ethtool speed or duplex
> > arguments while autoneg is on? Some possible answers are:
> >
> > a) Yell at the user for doing something stupid.
> >
> > b) Fail silently (i.e. ignore command).
> >
> > c) Change advertised value accordingly and initiate new negotiation.
> >
> > d) Consider "autoneg off" implied, force media accordingly.
> >
> > The ethtool(8) man page I'm looking at doesn't address that question.=
 The
> > actual behavior I've seen is b) which is by far my least preferred
> > solution.

> speed and duplex fields should be silently ignored in this case

I find the c) feature very convenient. For instance it allows reliably
downgrading a link connected to a switch without having to fiddle with
the configuration of the switch, something which is usually (pick your
favourites) non-standard, painful, not authorized, not implemented,
buggy,...

Command line parameters of the bcm5700=A0driver do implement c) (among
other nifties). Documented in its man page. Command line parameters of
e1000 also allow some control over the autonegociation process, even
if not using c) but a different (and less user-friendly) syntax. See
Documentation/--/e1000.txt. From David's words, I suspect this feature
is simply missing from ethtool.

Finally, silently ignoring user input is not very user-friendly IMHO.
I would much prefer a) to b).

I am aware that my preferences are probably in inverse order of the
amount of work required.



PS: I read netdev but not linux-kernel
