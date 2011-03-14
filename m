From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Mon, 14 Mar 2011 16:44:32 -0400
Message-ID: <AANLkTi=qi2GOprXEWCf6v=j=L98SQMdHb1OaHcdALepf@mail.gmail.com>
References: <1299894051-13820-1-git-send-email-ycheng@google.com>
	<201103141106.19679.carsten@wolffcarsten.de>
	<AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:48587 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757148Ab1CNUod convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 16:44:33 -0400
Received: by gwaa18 with SMTP id a18so1980865gwa.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 13:44:32 -0700 (PDT)
In-Reply-To: <AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 3:10 PM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff <carsten@wolffcarsten.=
de> wrote:
>> The moderation is in place to avoid gigantic segment bursts, which c=
ould cause
>> unnecessary pressure on buffers. In my eyes it's already suboptimal =
that the
>> moderation is weakened in the presence of (detected) reordering, let=
 alone
>> removing it completely.
>
> In the presence of reordering, cwnd is already moderated in Disorder
> state before
> =A0entering the (false) recovery.

I've always been somewhat skeptical of the usefulness of cwnd
moderation.  First, I don't know that its behavior is well defined.
When *should* tcp_moderate_cwnd() actually be called, and why?

Second, I've never liked the idea in general.  Reducing cwnd has an
effect lasting many RTTs, so reducing it in response to a transient
event like reordering seems dubious.  And it does not address many
causes of bursts, such as ack compression or stretch acks.

  -John
