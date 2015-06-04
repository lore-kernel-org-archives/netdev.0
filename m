From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC PATCH net-next] tcp: add CDG congestion control
Date: Thu, 4 Jun 2015 09:27:10 -0700
Message-ID: <CAA93jw7gNnr3OEJ8nJ0mj=hFOrObcatwEDVV6CXvtX28VCHO2g@mail.gmail.com>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
	<CAK6E8=eV=0YDs5VY8EfhnVH1=gEZ+X4OzZJzDZihvSOUq6ErGA@mail.gmail.com>
	<CA++eYdsG5Jw15BNqLv6AE3LivhsDpHNjRxvx3T3qZF248z6fRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	David Hayes <davihay@ifi.uio.no>,
	Andreas Petlund <apetlund@simula.no>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36842 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbbFDQ1L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:27:11 -0400
Received: by obbqz1 with SMTP id qz1so18072374obb.3
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:27:10 -0700 (PDT)
In-Reply-To: <CA++eYdsG5Jw15BNqLv6AE3LivhsDpHNjRxvx3T3qZF248z6fRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 9:19 AM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
>> why not just call tcp_init_cwnd_reduction()?
>
> I deferred considering the ECN implications of doing so. The code to
> start PRR was based on tcp_enter_cwr()/tcp_init_cwnd_reduction(), sav=
e
> that both of these functions ensure a call to tcp_ecn_queue_cwr().
>
> The upcoming patch set instead exports tcp_enter_cwr() and calls it,
> which sets CWR on ECN-capable connections.
>
> Consider CDG at the sender-side. The RFC 3168 Errata says that a
> receiver should:
> "First, reset ECE because of CWR
> Second, set ECE because of CE"
>
> Thus, in "good networks", setting CWR on a CDG backoff should not
> affect ECN signalling =E2=80=93 we still get ECE from the receiver.

On the AQM front I have been trying to deal with queue overload in the =
presence
of ECN with drop, then mark behavior. This handles the case of an unres=
ponsive
(lying) flow, and overload in general, on the queue side.

=2E.. however it is unclear to me how well various tcps are responding
to the combination
of these two signals, and finding a threshold to switch to drop + mark =
is hard.

I have certainly had cases where every incoming packet ended up marked
CE, to not
enough effect, fast enough.

> It is conceivable that fringe scenarios of ECN in the forward path an=
d
> losses in the ACK path creates a situation where CDG's backoff could
> inhibit some ECN signals from the receiver. That is, setting CWR will
> inhibit the signalling reliability of standard ECN in TCP. But we are
> arguably still in good faith since we have reduced the congestion
> window by some beta.



--=20
Dave T=C3=A4ht
What will it take to vastly improve wifi for everyone?
https://plus.google.com/u/0/explore/makewififast
