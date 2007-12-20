From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 10:49:22 -0800
Message-ID: <476AB932.8050606@intel.com>
References: <Pine.LNX.4.64.0712182046560.3616@mini.warudkars.net>	 <476AA0C3.2080503@intel.com> <82e4877d0712200956l4126e221qc0cf4720e59ca2a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: Parag Warudkar <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48051 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952AbXLTTKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:10:31 -0500
In-Reply-To: <82e4877d0712200956l4126e221qc0cf4720e59ca2a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parag Warudkar wrote:
> On Dec 20, 2007 12:05 PM, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>> I can't even apply this patch and the e1000 one... not only is it wh=
itespace
>> damaged it is also not properly formatted as patch at all. If you wa=
nt me to take
>> these patches seriously, then please fix the formatting issues.
>=20
> Sigh - I use Pine, follow Documents/email-clients.txt for the
> recommended settings and obviously the pathces are not generated with
> whitespace damage at my end as I test those before sending out.
>=20
> So although I hate to see this happen there is nothing at this moment
> that I can do - except for attaching the patch instead of inlining it=
=2E
> Since they have already been reviewed inline, please see if the
> attached patches work for you.

here's what the files in my Maildir spool look like in vim (my vim disp=
lays a '=BB'
char for tabs and a "=B6" for EOL):

 76 --- linux-2.6/drivers/net/e1000e/netdev.c=BB      2007-12-07 10:04:=
39.00000000
 77 +++ linux-2.6-work/drivers/net/e1000e/netdev.c=BB 2007-12-18 20:45:=
59.00000000
 78 @@ -3899,7 +3899,7 @@=B6
 79   =BB     =BB       goto err_eeprom;=B6
 80   =BB     }=B6
 81 =B6
 82 -=BB      init_timer(&adapter->watchdog_timer);=B6
 83 +=BB      init_timer_deferrable(&adapter->watchdog_timer);=B6
 84   =BB     adapter->watchdog_timer.function =3D &e1000_watchdog;=B6
 85   =BB     adapter->watchdog_timer.data =3D (unsigned long) adapter;=
=B6
 86 =B6
 87 --=B6

notice that there are two spaces instead of 1. Also there's no line hea=
ding the
diff with 'diff a/foo b/foo' which is what throws of stg. And the -p op=
tion is
missing.


as for content, the patch looks OK with me. I ran the numbers and allth=
ough there
was a slight average delay in the link up detection time it is negligea=
ble (less
than 0.2sec difference over a bunch of measurements), and I confirmed y=
our
powertop numbers are correct. As for the timer interval, the watchdog m=
ay already
be delayed up to 3 seconds safely, this doesn't change that.

I'll forward the patch, Care to make one for e100? plenty of laptops wi=
th those
still around! The embedded guys would love it I think.

Thanks,

Auke

