From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Mon, 02 Jul 2007 22:14:54 -0700 (PDT)
Message-ID: <20070702.221454.18562227.davem@davemloft.net>
References: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
	<20070615.151439.70217492.davem@davemloft.net>
	<Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52441
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbXGCFOf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 01:14:35 -0400
In-Reply-To: <Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 16 Jun 2007 02:04:25 +0300 (EEST)

> There are still some things I must think carefully in sacktag process=
ing=20
> since it does not validate start_seq and end_seq at all which can be=20
> abused currently at least in tcp-2.6. ...I would rather put end to th=
e=20
> whole russian roulette in tcp-2.6 sacktag rather than fix/think indiv=
idual=20
> cases and leave future modifications of it similarily hazardous. It's=
 not=20
> very clear to me how to handle all possible cases of invalid SACK blo=
cks=20
> though, perhaps TCP should just ignore such sack blocks without doing=
=20
> any processing based on them, i.e., ignore them whenever start_seq-en=
d_seq=20
> does not fully fit to snd_una-snd_nxt (expect DSACK of course, which=20
> should be processed if it's between undo_marker-snd_nxt). Do you have=
 any=20
> thoughts about this?

I agree.  This is a problem that basically every single TCP stack out
there right now is vulnerable to, lots of cpu processing for invalid
or maliciously created SACK blocks.  This is why I even considered the
RB-Tree stuff at all.

Therefore the earlier we toss out bad SACK blocks the better, and thus
I agree with a scheme that does validation at the earliest stage
possible as you seem to be suggesting.
