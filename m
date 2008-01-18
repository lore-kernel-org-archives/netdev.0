From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Fri, 18 Jan 2008 09:34:22 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801180932440.4570@bizon.gios.gov.pl>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org>
 <Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl>
 <20080114144754.29a448ad.akpm@linux-foundation.org> <16796.1200351673@death>
 <20080117154243.9ee4265c.akpm@linux-foundation.org> <24607.1200616005@death>
 <Pine.LNX.4.64.0801180154570.4570@bizon.gios.gov.pl> <27063.1200620733@death>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-41807400-1200645262=:4570"
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:39854 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbYARIfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 03:35:05 -0500
In-Reply-To: <27063.1200620733@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-41807400-1200645262=:4570
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 17 Jan 2008, Jay Vosburgh wrote:

> Krzysztof Oledzki <olel@ans.pl> wrote:
>
>>> Andrew Morton <akpm@linux-foundation.org> wrote:
>>> [...]
>>>> Can we get this bug fixed please?  Today?  It has been known about for=
 more
>>>> than two months.
>>>
>>> =09I just reposted the complete fix; it's #1 of the series of 7.
>>
>> Bad news. :( 2.6.24-rc7 + patch #1 (bonding: fix locking in sysfs
>> primary/active selection):
> [...]
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
>> [ INFO: possible irq lock inversion dependency detected ]
>> 2.6.24-rc7 #1
>> ---------------------------------------------------------
>> events/0/9 just changed the state of lock:
>> (&mc->mca_lock){-+..}, at: [<c041255a>] mld_ifc_timer_expire+0x130/0x1fb
>> but this lock took another, soft-read-irq-unsafe lock in the past:
>> (&bond->lock){-.--}
>
> =09None of the seven patches I posted just a bit ago will fix this
> lockdep warning (which is a different thing that the bug Andrew inquired
> about); I'm still working on that one.
>
> =09For that one, I had posted this work in progress patch:

Yes, this one works.

> =09which makes the warning go away, but Herbert Xu pointed out that
> there is a potential problem with bond_enslave accessing the mc_lists
> without sufficient locking.  It's not the only offender, either, and the
> bond->mc_list references really need to be protected by the bond_lock,
> and the whole thing probably ought to use dev_mc_sync/unsync instead of
> what it does now.
>
> =09Since the bond_enslave, et al, business isn't a new problem, and
> I've never heard of it being hit, I'm thinking now to just leave the
> bond_enslave part for 2.6.25, and fix the lockdep warning for 2.6.24.

It is a new problem, as it never happened with <=3D2.6.23.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-41807400-1200645262=:4570--
