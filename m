From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH 2/3] sky2: Reading registers in reset causes a hang
Date: Tue, 13 Oct 2009 07:36:45 +0900
Message-ID: <392fb48f0910121536x3e7c37fbjd83ef821b3617644@mail.gmail.com>
References: <4AD337ED.4090409@ring3k.org> <20091012091459.49eb1188@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:38149 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758157AbZJLWpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 18:45:33 -0400
Received: by ewy28 with SMTP id 28so3155255ewy.18
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 15:44:56 -0700 (PDT)
In-Reply-To: <20091012091459.49eb1188@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/10/13 Stephen Hemminger <shemminger@linux-foundation.org>
>
> On Mon, 12 Oct 2009 23:06:37 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
>
> > When sky2 hardware is in reset, reading registers with ethtool -d
> > causes a hard system hang. eg.
> >
> > =C2=A0 =C2=A0 ifconfig eth1 down
> > =C2=A0 =C2=A0 ethtool -d eth1
> >
> > Avoid reading FIFOs, descriptor and status unit, etc. after we've
> > =C2=A0bought the interface down, as these seem to cause the issue.
> >
> > Assume the same is true for the second port, as my port only has
> > =C2=A0one card.
>
> I don't see this on my cards. Let me investigate further before
> committing this. Also, the debugfs interface would also be screwed
> if the registers were unavailable.

I forgot to include one other piece of information... I'm running a
ping -f at the sky2 interface on a remote machine. I'll check debugfs
tonight.

thanks,

Mike
