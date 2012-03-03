From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix tcp_retransmit_skb() to maintain MSS invariant
Date: Sat, 3 Mar 2012 02:44:38 -0500
Message-ID: <CADVnQy=MxPbbg+fVAU_dGwsZotbbnFMvbrtEHGb+MkQfNkioOA@mail.gmail.com>
References: <1330698449-2969-1-git-send-email-ncardwell@google.com>
	<alpine.DEB.2.00.1203022147100.3978@melkinpaasi.cs.helsinki.fi>
	<CAK6E8=eqAgw3_eMnvZUmDnHT0ETPFvDC2=HG3uj5nr3kGL7J5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.216.179]:65316 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786Ab2CCHoj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 02:44:39 -0500
Received: by qcha6 with SMTP id a6so998787qch.10
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 23:44:38 -0800 (PST)
In-Reply-To: <CAK6E8=eqAgw3_eMnvZUmDnHT0ETPFvDC2=HG3uj5nr3kGL7J5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 2, 2012 at 10:05 PM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> On Fri, Mar 2, 2012 at 12:25 PM, Ilpo J=E4rvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
>> Why would we be splitting SACKed segment there?!? ...Ah, it seems th=
at
>> it indeed is possible now after the non-FACK mode fragment, however,=
 it
>> is totally useless work and seems to be breaking stuff. I think that=
 the
>> proper solution is to prevent splitting of already SACKed stuff. ...=
Nice
>> find btw. :-)
>
> Bingo! I totally agree this is the bug. looks like a one-line patch n=
ow.

Agreed. I sent out a proposal:
  http://patchwork.ozlabs.org/patch/144408/

Thanks, Ilpo, for filling in the details. The comment in
tcp_match_skb_to_sack() that says "Round if necessary so that SACKs
cover only full MSSes and/or the remaining small portion (if
present)", plus the analogous MSS alignment logic in
tcp_mss_split_point(), had me convinced that this MSS alignment
invariant that was needed for tcp_match_skb_to_sack() to work
correctly was actually intended.

neal
