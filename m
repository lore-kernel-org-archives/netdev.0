From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [patch] sunrpc: make closing of old temporary sockets work (was: problems with lockd in 2.6.22.6)
Date: Fri, 14 Sep 2007 11:12:30 +0200
Message-ID: <200709141112.30634.wolfgang.walter@studentenwerk.mhn.de>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de> <200709122140.57783.wolfgang.walter@studentenwerk.mhn.de> <20070912195512.GC13792@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Brown <neilb@suse.de>, trond.myklebust@fys.uio.no,
	netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:53202 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751876AbXINJMc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 05:12:32 -0400
In-Reply-To: <20070912195512.GC13792@fieldses.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 12. September 2007 21:55 schrieb J. Bruce Fields:
> On Wed, Sep 12, 2007 at 09:40:57PM +0200, Wolfgang Walter wrote:
> > On Wednesday 12 September 2007, J. Bruce Fields wrote:
> > > On Wed, Sep 12, 2007 at 04:14:06PM +0200, Neil Brown wrote:
> > > > So it is in 2.6.21 and later and should probably go to .stable =
for
> > > > .21 and .22.
> > > >
> > > > Bruce:  for you :-)
> > >
> > > OK, thanks!  But, (as is alas often the case) I'm still confused:
> > > >  		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
> > > >  			continue;
> > > > -		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY,
> > > > &svsk->sk_flags)) +		if (atomic_read(&svsk->sk_inuse) > 1
> > > > +		    || test_bit(SK_BUSY, &svsk->sk_flags))
> > > >  			continue;
> > > >  		atomic_inc(&svsk->sk_inuse);
> > > >  		list_move(le, &to_be_aged);
> > >
> > > What is it that ensures svsk->sk_inuse isn't incremented or SK_BU=
SY set
> > > after that test?  Not all the code that does either of those is u=
nder
> > > the same serv->sv_lock lock that this code is.
> >
> > This should not matter - SK_CLOSED may be set at any time.
> >
> > svc_age_temp_sockets only detaches the socket, sets SK_CLOSED and t=
hen
> > enqueues it. If SK_BUSY is set its already enqueued and svc_sock_en=
queue
> > ensures that it is not enqueued twice.
>
> Oh, got it.  And the list manipulation is safe thanks to sv_lock.  Ne=
at,
> thanks.  Can you verify that this solves your problem?

Patch works fine here.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
