From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next] tcp: Fix CWV being too strict on thin streams
Date: Wed, 23 Sep 2015 14:37:58 -0400
Message-ID: <CADVnQymaAjyRyJjh0pbqrjP3j+BbqUV4z7OWiuu0wTphz47Vwg@mail.gmail.com>
References: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel+kernel@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Mads Johannessen <madsjoh@ifi.uio.no>
To: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34220 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbbIWSh7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:37:59 -0400
Received: by oiev17 with SMTP id v17so29011814oie.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 11:37:58 -0700 (PDT)
In-Reply-To: <1443026993-12358-1-git-send-email-bro.devel+kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 12:49 PM, Bendik R=C3=B8nning Opstad
<bro.devel@gmail.com> wrote:
> Application limited streams such as thin streams, that transmit small
> amounts of payload in relatively few packets per RTT, can be prevente=
d
> from growing the CWND when in congestion avoidance. This leads to
> increased sojourn times for data segments in streams that often trans=
mit
> time-dependent data.
>
> Currently, a connection is considered CWND limited only after having
> successfully transmitted at least one packet with new data, while at =
the
> same time failing to transmit some unsent data from the output queue
> because the CWND is full. Applications that produce small amounts of
> data may be left in a state where it is never considered to be CWND
> limited, because all unsent data is successfully transmitted each tim=
e
> an incoming ACK opens up for more data to be transmitted in the send
> window.
>
> Fix by always testing whether the CWND is fully used after successful
> packet transmissions, such that a connection is considered CWND limit=
ed
> whenever the CWND has been filled. This is the correct behavior as
> specified in RFC2861 (section 3.1).
>
> Cc: Andreas Petlund <apetlund@simula.no>
> Cc: Carsten Griwodz <griff@simula.no>
> Cc: Jonas Markussen <jonassm@ifi.uio.no>
> Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> Cc: Mads Johannessen <madsjoh@ifi.uio.no>
> Signed-off-by: Bendik R=C3=B8nning Opstad <bro.devel+kernel@gmail.com=
>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>

I ran all the Google packetdrill test cases with this patched in, and
all still pass.

I also re-ran the test I posted in the v1 thread (based on Eric's
test), and it still passes.

neal
