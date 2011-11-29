From: Dave Taht <dave.taht@gmail.com>
Subject: Re: is non-inheritance of congestion control algorithm from the
 listen socket a bug or a feature?
Date: Tue, 29 Nov 2011 21:27:35 +0100
Message-ID: <CAA93jw65f3SobpmD-pb16o0Eu83PRBDmN_ANZ4qMe3i-0fLYWw@mail.gmail.com>
References: <4ED53AA1.9090800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:59275 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab1K2U1g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 15:27:36 -0500
Received: by pzk36 with SMTP id 36so8275938pzk.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 12:27:35 -0800 (PST)
In-Reply-To: <4ED53AA1.9090800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey, thx for trying it!

On Tue, Nov 29, 2011 at 9:03 PM, Rick Jones <rick.jones2@hp.com> wrote:

>
> Is the non-inheritance of the congestion control algorithm a bug or a
> feature?

Hmm... It's kind of both.

Recently I submitted an RFC patch to the
rsync mailing list, and it seemed nice to be able to set it on a per
socket basis based on various configuration options in the
rsync conf file and what was explicitly allowed.

That patch is here:

https://lists.samba.org/archive/rsync/2011-November/027111.html

It was also way cool to see tcp-lp in action vs other sorts of tcp.

That said we  have a range of allowable congestion algorithms
ranging from more intense than cubic to low bandwidth to wireless,
to highly specialized (data center tcp), to some that require
both sides to be running the same alg, others that are server
only...

Your question sort of involves what should a user be able
to set.

On the one hand, in the general case an app should
not be allowed to choose a more aggressive tcp.

On the other hand, an app on a wireless box,
requesting/getting, say, westwood over a default of lp or cubic sort
of makes sense.

On the gripping hand I thiink pushing this level of decison
making out to the app is just fine by me, so inherit
or not, is the app's call to setsockopt...

And in netperf's case, that would be all the algs made
available via allowable_congestion_control.

I had another idea regarding pushing alternate tcp algos out
to more apps without requiring source code changes,
which would be to create a cgroup controller, which
would be both trendy and would provide 'inherit-ability'...

But first up I think would be for more folk to see how
cool different algos can be.

>
> rick jones
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
