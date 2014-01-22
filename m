From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Thu, 23 Jan 2014 01:11:52 +0400
Message-ID: <CAMrnHh5od13Ydo12Dt4OTa3nw+5om5LYO53iu9nQYqWeBxMPAw@mail.gmail.com>
References: <1390401156.61208.YahooMailBasic@web125501.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>
To: =?ISO-8859-1?Q?Fran=E7ois=2DXavier_Le_Bail?= <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:54179 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbaAVVLw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 16:11:52 -0500
Received: by mail-ie0-f179.google.com with SMTP id ar20so121477iec.38
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 13:11:52 -0800 (PST)
In-Reply-To: <1390401156.61208.YahooMailBasic@web125501.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Wed, Jan 22, 2014 at 6:32 PM, Fran=E7ois-Xavier Le Bail
<fx.lebail@yahoo.com> wrote:
>> Actually, I was alerted by reset processing in your patch, it cannot=
 be right.
>
> Perhaps, I missed something.

Perhaps, I missed something. According to my old knowledge, tcp cannot
be used with anycasts
by many reasons and I have no idea what could change to the moment.

=46.e. what do you do when a segment arrives on listening socket w/o
connection associated?
If you sent reset, you could reset someone's valid connection (I mean
this, saying "it cannot be right").
If you do not, you violate protocol, those resets are required to
clean up stale states.

>> Do not you think this must not be enabled for common use? At least
>> some separate sysctl disabled by default.
>
> We could indeed use a sysctl, disabled by default.
>
> But my goal was to enable anycast address usage transparently, if pos=
sible.

IMHO it is logically impossible. That's why my first question was
about a document which
allowed anycasts with TCP. (BTW I found your answer unconvincing, at le=
ast.)
Traditional anycasting used to be stateless and it was impossible to
use with TCP
because unsynchronized TCP connections would be unavoidable.
AFAIK only suggestion from ancient RFC1546 could cure this problem,
but it is very tricky and implies client knows that destination is anyc=
ast.

Actually, I do not even understand how the idea of use of anycast with =
TCP
emerged. The only situation I can imagine: the router is expected to
do full scale
connection tracking and to bind connections to anycast destinations to
correct nodes.
(And the same moment you understand that the notion of anycast is
completely lost
in this picture: the same thing is done by load balancers in IPv4 for
unicast addresses
for ages) I still have no idea how it is going to work when both
client and servers bound
to anycasts are on the same link.

So, it looks like you need this sysctl to announce: "someone cares
about proper routing
on this network and tcp should work". It looks obvious this mode
cannot be enabled by default.

Alexey
