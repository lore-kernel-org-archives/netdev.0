From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Mon, 14 Mar 2011 12:10:22 -0700
Message-ID: <AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
References: <1299894051-13820-1-git-send-email-ycheng@google.com> <201103141106.19679.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49191 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab1CNTKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 15:10:45 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p2EJAh6V011378
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 12:10:44 -0700
Received: from vws17 (vws17.prod.google.com [10.241.21.145])
	by kpbe14.cbf.corp.google.com with ESMTP id p2EJ9bdk023669
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 12:10:42 -0700
Received: by vws17 with SMTP id 17so3702599vws.18
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 12:10:42 -0700 (PDT)
In-Reply-To: <201103141106.19679.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff <carsten@wolffcarsten.de> wrote:
> The moderation is in place to avoid gigantic segment bursts, which could cause
> unnecessary pressure on buffers. In my eyes it's already suboptimal that the
> moderation is weakened in the presence of (detected) reordering, let alone
> removing it completely.

In the presence of reordering, cwnd is already moderated in Disorder
state before
 entering the (false) recovery.


>
> More importantly, the prior ssthresh is restored and not affected by
> moderation. This means, if moderation reduces cwnd to a small value, then cwnd
> < ssthresh and TCP will quickly slow-start back to the previous state, without
> sending a big burst of segments.
>
> Also, you intended to remove cwnd moderation only from an undo during
> recovery, but I think your patch also removes cwnd moderation when the undo is
> caused by D-SACK, i.e. most likely after recovery already ended.

Thanks. I will update my patch description. But the same principle
applies that cwnd
should not be moderated on false events. Whether it should be moderated on
reordering or other events is another (complex) design issue. But this
patch does not
touch that.

Yuchung
