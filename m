From: jamal <hadi@cyberus.ca>
Subject: Re: Network activity LED trigger
Date: Fri, 02 Mar 2007 10:16:58 -0500
Message-ID: <1172848619.4845.17.camel@localhost>
References: <200703012241.49165.florian.fainelli@int-evry.fr>
	 <200703021358.52224.florian.fainelli@int-evry.fr>
	 <1172844668.4864.46.camel@localhost>
	 <200703021516.06638.florian.fainelli@int-evry.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Richard Purdie <rpurdie@rpsys.net>
To: Florian Fainelli <florian.fainelli@int-evry.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:61072 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992504AbXCBPRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 10:17:03 -0500
Received: by wx-out-0506.google.com with SMTP id h31so788196wxd
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 07:17:02 -0800 (PST)
In-Reply-To: <200703021516.06638.florian.fainelli@int-evry.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-02-03 at 15:16 +0100, Florian Fainelli wrote:
> Hi,
>=20
> Le vendredi 2 mars 2007, jamal a =E9crit :
> > Where are these LEDs typically located? Are you talking about LEDs =
on a
> > network card for example? can you light them up in different colors=
?
>=20
> Those LEDS are typically controlled by GPIO lines visible in front of=
 the=20
> device. It is mostly targeted to embedded devices for which you do no=
t=20
> necessarily want to assign a LED to a given network interface
>=20

Ah, ok - ive worked with a not-so-embedded board that had something tha=
t
was accessible via the ICH; i recall writting a user-space program to
handle it. So instead of calling this just LED, probably find a more
descriptive name for it; Example GPIO-LED.

Those things are tricky to have in a generic code though, no? I.e each
chipset/board will have different address mappings on where to
read/write for a specific LED. So you need to deal with that problem
without requiring changing of the kernel every time an address changes.
I actually found exactly similar board (some manufacturer) but the
firmware was slightly different.

Heres my view of what would be useful:
Have them accessible via the kernel, but also have an API from user
space. This way user space apps can control the LED, but if i wanted to
do it from the kernel i could as well. In my case i was actually
monitoring the health of a daemon; it would show off if the daemon was
not running, green if it was happy, yellow if semi-healthy and Red if i=
t
was in trouble.

here are some operations/messages i can see that are useful which you
probably already have in your API:

turn on LED at #x color somecolor
turn off LED at #y
query LED info at #x
dump all LEDs on board - think of this as a discovery
flicker LED at #z at frequency y color green
maybe even: "I am a wireless card with no LED, I claim LED #x"
which is matched by "tell me if anyone owns LED code"

In other words, if you just provide mechanims let people write the
policies.
This way if i wanted to tie it to my eth0 i can.=20

Hope that helps.

cheers,
jamal


