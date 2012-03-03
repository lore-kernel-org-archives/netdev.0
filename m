From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: fix tcp_retransmit_skb() to maintain MSS invariant
Date: Fri, 2 Mar 2012 19:05:07 -0800
Message-ID: <CAK6E8=eqAgw3_eMnvZUmDnHT0ETPFvDC2=HG3uj5nr3kGL7J5A@mail.gmail.com>
References: <1330698449-2969-1-git-send-email-ncardwell@google.com> <alpine.DEB.2.00.1203022147100.3978@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:56424 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750837Ab2CCDF2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 22:05:28 -0500
Received: by obbuo6 with SMTP id uo6so2375900obb.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 19:05:27 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1203022147100.3978@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 2, 2012 at 12:25 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> Why would we be splitting SACKed segment there?!? ...Ah, it seems tha=
t
> it indeed is possible now after the non-FACK mode fragment, however, =
it
> is totally useless work and seems to be breaking stuff. I think that =
the
> proper solution is to prevent splitting of already SACKed stuff. ...N=
ice
> find btw. :-)

Bingo! I totally agree this is the bug. looks like a one-line patch now=
=2E

We _really_ need to refactor the cryptic tcp_mark_head_lost(). I have a=
 patch
ready for review once the recent sack turmoil settles.
