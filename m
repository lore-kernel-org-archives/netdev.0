From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Bug 7635] New: ioctl(fd,TCSBRK,1) on socket yields EFAULT,
 expected EINVAL/ENOTTY
Date: Sat, 09 Dec 2006 09:06:27 +0100
Message-ID: <457A6E83.2070708@cosmosbay.com>
References: <20061208095055.38fef768@localhost>
 <20061208.133633.77400985.davem@davemloft.net>
 <20061208140021.27e9ab2d@freekitty>
 <20061208.163349.74721527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:39860 "EHLO smTp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760517AbWLIIGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Dec 2006 03:06:16 -0500
Received: from [192.168.30.10] ([84.7.129.212]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J9Z009NVYIBR222@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Sat, 09 Dec 2006 09:06:11 +0100 (CET)
In-reply-to: <20061208.163349.74721527.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 8 Dec 2006 14:00:21 -0800
>=20
>> That is not true on BSD or other unix standardish ioctl's.
>> There are no conflicts between the TIOC... values and the SIOC... va=
lues
>=20
> There is absolutely nothing that we can do about this under
> Linux without breaking every single application out there.
>=20
> We allocated these values a long long time ago, before we
> got the idea that we should perhaps use some kind of
> macro system (as we mostly do now) to keep the values from
> conflicting.
>=20
>> Seems like one of those annoying standards compliance test
>> return value bugs that shouldn't really hit an application.
>=20
> Being non-compliant, and being unable to become compliant,
> it actually a feature and a huge weight off of our shoulders,
> don't you think?  :-)

Well, as long you/we dont break isattty() (which try an=20
ioctl(fd,TCGETS,&termios) on the fd), it should be OK.

So TCGETS *MUST* return an error on a socket (and other non tty files)

Eric
