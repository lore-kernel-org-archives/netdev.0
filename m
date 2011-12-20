From: Mathieu Trudel-Lapierre <mathieu-tl@ubuntu.com>
Subject: Re: [PATCH] ipv6: make the net.ipv6.conf.all.use_tempaddr sysctl
 propagate to interface settings
Date: Mon, 19 Dec 2011 21:04:15 -0500
Message-ID: <CACfMzvqtRTeFy0Q8yt-e9B5ndrBsNmhQ4q12LBndTrdyMfYnLg@mail.gmail.com>
References: <1324071933-2961-1-git-send-email-mathieu.trudel-lapierre@canonical.com>
	<20111219.161624.488823593081231376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mathieu.trudel-lapierre@canonical.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:33120 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab1LTCER convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 21:04:17 -0500
Received: by iaeh11 with SMTP id h11so9449851iae.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 18:04:16 -0800 (PST)
In-Reply-To: <20111219.161624.488823593081231376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 4:16 PM, David Miller <davem@davemloft.net> wro=
te:
> "all" settings must be in place before the device is created and come=
s up.
>
> You can't just "propagate" to the existing devices when the "all"
> setting is changed, because an individual device might have had it's
> independent sysctl setting modified by the administrator and you'll b=
e
> smashing that.
>
> I'm not applying this patch.

Would it be possible in this case to update the documentation to make
this clear? I'm certainly not the only one who has come up with the
question. What seems to come up often is confusion between the purpose
of "default" and that of "all". My understanding really was that
*default* is meant to be set before the devices are created and come
up.

I believe use_tempaddr is a special case in which if you want to
enable it, you'll likely want to have it set globally; at least that
seems the case for mobile systems where this appears to me as making
the most sense. Distributions may want to set a defaut for
installations being that temporary addresses are enabled by default,
which tends to be very impractical to do any other way (interfaces
don't all come up at the same time; on my system at least eth0 comes
up very early, before sysctls can be applied in userland). Dealing
with this particular issue at the distribution level, you can't know
in advance what interfaces are on the system. It seems as though
setting:

net.ipv6.conf.all.use_tempaddr=3D2
net.ipv6.conf.default.use_tempaddr=3D2

Should be sufficient to enable privacy addresses everywhere, at boot.
This wouldn't be particularly different from disabling ipv6 with the
sysctls, I think.

Besides the issue of smashing settings applied by administrators, is
there something else I'm missing?

Kind regards,

Mathieu Trudel-Lapierre <mathieu-tl@ubuntu.com>
=46reenode: cyphermox, Jabber: mathieu.tl@gmail.com
4096R/EE018C93 1967 8F7D 03A1 8F38 732E =C2=A0FF82 C126 33E1 EE01 8C93
