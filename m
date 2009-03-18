From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 17:54:04 -0400
Message-ID: <49C16D7C.3080003@novell.com>
References: <87prge1rhu.fsf@basil.nowhere.org>	<20090318.140340.55290859.davem@davemloft.net>	<49C16349.9030503@us.ibm.com> <20090318.143844.173112261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9AC78968E5C3E9223B4E1D9D"
Cc: vernux@us.ibm.com, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org,
	Patrick Mullaney <pmullaney@novell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:37388 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760270AbZCRVvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 17:51:46 -0400
In-Reply-To: <20090318.143844.173112261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9AC78968E5C3E9223B4E1D9D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Vernon Mauery <vernux@us.ibm.com>
> Date: Wed, 18 Mar 2009 14:10:33 -0700
>
>  =20
>> David Miller wrote:
>>    =20
>>> From: Andi Kleen <andi@firstfloor.org>
>>> Date: Wed, 18 Mar 2009 21:54:37 +0100
>>>
>>>      =20
>>>> But then again I'm not sure it's  worth it if the problem only
>>>> happens in out of tree RT.
>>>>        =20
>>> The list of problems that only show up with the RT kernel seems to be=

>>> constantly increasing, but honestly is very surprising to me.
>>> I don't understand why we even need to be concerned about this stuff
>>> upstream, to be honest.
>>> Please reproduce this in the vanilla kernel, then get back to us.
>>>      =20
>> Huh? The numbers that I posted *were* from the vanilla kernel. I ran
>> the 2.6.29-rc8 kernel with lock_stat enabled.  The lock contention
>> happens on the same lock in both vanilla and -rt, it just happens
>> to be more pronounced in the -rt kernel because of the double context
>> switches that the sleeping spinlock/rt-mutexes introduce.
>>    =20
>
> And the double context switches are probably also why less
> natural batching and locality are achieved in the RT kernel.
>
> Isn't that true?
>  =20

Note that -rt doesnt typically context-switch under contention anymore
since we introduced adaptive-locks.  Also note that the contention
against the lock is still contention, regardless of whether you have -rt
or not.  Its just that the slow-path to handle the contended case for
-rt is more expensive than mainline.  However, once you have the
contention as stated, you have already lost.

We have observed the posters findings ourselves in both mainline and
-rt.  I.e. That lock doesnt scale very well once you have more than a
handful of cores.  It's certainly a great area to look at for improving
the overall stack, IMO, as I believe there is quite a bit of headroom
left to be recovered that is buried there.

Regards,
-Greg


--------------enig9AC78968E5C3E9223B4E1D9D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknBbX0ACgkQlOSOBdgZUxmV+ACggmy0luFTSy5MC4e8WuKT+e5n
/d4AnifozXgtOcrZoVtFlF8ToUaOcTSp
=fBwN
-----END PGP SIGNATURE-----

--------------enig9AC78968E5C3E9223B4E1D9D--
