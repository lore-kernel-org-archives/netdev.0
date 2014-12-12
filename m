From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] Avoid reducing cwnd when ACK+DSACK is received
Date: Fri, 12 Dec 2014 10:54:11 -0500
Message-ID: <CADVnQy=N2VAZjt_kprfg3ZBk8-Xu=v-7ohGY=Vy+PQ_w2ZRn1g@mail.gmail.com>
References: <1418327890-368-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:62391 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336AbaLLPyM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 10:54:12 -0500
Received: by mail-qa0-f42.google.com with SMTP id j7so5355731qaq.1
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 07:54:12 -0800 (PST)
In-Reply-To: <1418327890-368-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2014 at 2:58 PM, S=C3=A9bastien Barr=C3=A9
<sebastien.barre@uclouvain.be> wrote:
> When the peer has delayed ack enabled, it may reply to a probe with a=
n
> ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
> such ACK+DSACK will be missed and only at next, higher ack will the T=
LP
> episode be considered done. Since the DSACK is not present anymore,
> this will cost a cwnd reduction.
>
> This patch ensures that this scenario does not cause a cwnd reduction=
, since
> receiving an ACK+DSACK indicates that both the initial segment and th=
e probe
> have been received by the peer.
>
> Cc: Gregory Detal <gregory.detal@uclouvain.be>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.b=
e>

BTW, I like this idea, and I'll test it.

Two suggestions for the next iteration:

(1) for TCP patch style, I'd suggest a commit first-line like:

  tcp: avoid reducing cwnd when ACK+DSACK is received

(2) Your patch is essentially a reworking of the is_tlp_dupack
computation. So rather than splitting the logic between the
is_tlp_dupack computation and the new expression inside the if
condition, I'd suggest moving and centralizing all the logic in the if
condition. There is no real need for the is_tlp_dupack variable.

neal
