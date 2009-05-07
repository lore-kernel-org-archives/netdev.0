From: Frans Pop <elendil@planet.nl>
Subject: Re: Strange Application bug, race in MSG_PEEK complaints (was: Bug#513695: fetchmail: race in MSG_PEEK)
Date: Thu, 7 May 2009 19:16:56 +0200
Message-ID: <200905071916.57903.elendil@planet.nl>
References: <200902262310.12791.elendil@planet.nl> <20090506230240.GA10373@merlin.emma.line.org> <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Andree <matthias.andree@gmx.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml103.kpnxchange.com ([195.121.3.7]:58282 "EHLO
	CPSMTPM-EML103.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753399AbZEGRQ7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 13:16:59 -0400
In-Reply-To: <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 May 2009, Ilpo J=C3=A4rvinen wrote:
> On Thu, 7 May 2009, Matthias Andree wrote:
> > I've applied the following patch to net/ipv4/tcp.c for the kernel
> > running on my server (2.6.29-rc8):
> > @@ -1499,8 +1499,9 @@ do_prequeue:
> >    		}
> >    		if ((flags & MSG_PEEK) && peek_seq !=3D tp->copied_seq) {
> >    			if (net_ratelimit())
> > -				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PE=
EK.\n",
> > -				       current->comm, task_pid_nr(current));
> > +				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PE=
EK: %x, %x.\n",
> > +				       current->comm, task_pid_nr(current)),
> > +				       peek_seq, tp->copied_seq;
>
> I cannot resist myself from noting that this certainly wasn't the pat=
ch
> one got those printks below... It might happily compile though :-).

Can you please elaborate why you think that? It may be horribly broken
(I've never claimed to be a C coder, and probably never will), but it
also really is the patch that generates the printks...

> >    			peek_seq =3D tp->copied_seq;
> >    		}
> >    		continue;
> >
> > So, the values you see at the end of the warning are peek_seq and
> > tp->copied_seq. This gives messages like:
> > kernel: TCP(fetchmail:9311): Application bug, race in MSG_PEEK: 156=
233, 16a.
> > kernel: TCP(fetchmail:9311): Application bug, race in MSG_PEEK: 712=
59ac8, 5b4.
> > kernel: TCP(fetchmail:31216): Application bug, race in MSG_PEEK: 83=
3fe5, c0.

[...]

> What would you think about the following, untested patch... I suppose
> it is enough to capture the racy situations except with that crazy ur=
g
> hole, grr (I suppose that will need just another variable to do the
> offset of one).

I'll give your patch a try and report back.

Thanks,
=46JP
