From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint
 for FACK
Date: Mon, 27 Feb 2012 21:40:03 -0500
Message-ID: <CADVnQym_a=QDyjGX=L6-o3orxPdKJOwVZNfutaW5ZHAt=aB21A@mail.gmail.com>
References: <1329200528-19718-1-git-send-email-ncardwell@google.com>
	<20120214.144033.848861752845052421.davem@davemloft.net>
	<alpine.DEB.2.00.1202280127490.17924@melkinpaasi.cs.helsinki.fi>
	<alpine.DEB.2.00.1202280141380.18668@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	ycheng@google.com, therbert@google.com, subramanian.vijay@gmail.com
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43717 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203Ab2B1CkE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 21:40:04 -0500
Received: by iagj37 with SMTP id j37so603932iag.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 18:40:04 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1202280141380.18668@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, I agree that it would make sense to hold off on adding these
three 3.3-rc4 commits to the stable tree:

cc9a672ee522d4805495b98680f4a3db5d0a0af9

daef52bab1fd26e24e8e9578f8fb33ba1d0cb412

0af2a0d0576205dda778d25c6c344fc6508fc81d

It would make sense to let the dust settle a bit more before adding
those to the stable tree.

The same goes for the http://patchwork.ozlabs.org/patch/143114/ patch
(under review) that is in the same area of the code.

neal

On Mon, Feb 27, 2012 at 6:43 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> ...Grr, I picked up Greg's new address but ended still using his old =
one.
> The correct is one now added.
>
> On Tue, 28 Feb 2012, Ilpo J=E4rvinen wrote:
>
>> On Tue, 14 Feb 2012, David Miller wrote:
>>
>> > From: Neal Cardwell <ncardwell@google.com>
>> > Date: Tue, 14 Feb 2012 01:22:08 -0500
>> >
>> > > This commit ensures that lost_cnt_hint is correctly updated in
>> > > tcp_shifted_skb() for FACK TCP senders. The lost_cnt_hint adjust=
ment
>> > > in tcp_sacktag_one() only applies to non-FACK senders, so FACK s=
enders
>> > > need their own adjustment.
>> > >
>> > > This applies the spirit of 1e5289e121372a3494402b1b131b41bfe1cf9=
b7f -
>> > > except now that the sequence range passed into tcp_sacktag_one()=
 is
>> > > correct we need only have a special case adjustment for FACK.
>> > >
>> > > Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> >
>> > Applied, and queued up for -stable, thanks Neil.
>>
>> There has been lots of TCP related warnings posted recently to netde=
v.
>> Finding out which of these three recent changes caused which warning=
 and
>> if they're all cured by the full series is bit challenging. ...IMHO =
we
>> should wait a bit more until these recent fixes are put to stable in=
 order
>> to verify that the dust has really settled.
