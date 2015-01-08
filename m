From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 08 Jan 2015 09:27:54 -0800
Message-ID: <1420738074.5947.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	 <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54AEA498.5030202@uclouvain.be>
	 <CADVnQy=A57TUYD=kGtZXvq7-FGSN=vN3D2heaNCnBB=zjujwUg@mail.gmail.com>
	 <1420734325.5947.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1420737469.5947.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:44679 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299AbbAHR2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 12:28:00 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so3250231qcx.2
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 09:28:00 -0800 (PST)
In-Reply-To: <1420737469.5947.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-08 at 09:17 -0800, Eric Dumazet wrote:

> BTW, tlp_high_seq is used no matter what (initial value is 0).
> 
> While the probability ACK seq being exactly 0 is small (1 out of 2^32),
> probability that !before(ack, tp->tlp_high_seq) being a false positive
> is very high. Initial sequence number are supposed to be random.
> 

Oh well, calls to tcp_process_tlp_ack() are guarded by :

if (tp->tlp_high_seq)
    tcp_process_tlp_ack(sk, ack, flag);
