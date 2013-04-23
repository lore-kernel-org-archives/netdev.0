From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] Net: rxrpc: signed and unsigned issue, need type cast
 for n_elem.
Date: Tue, 23 Apr 2013 09:24:48 +0800
Message-ID: <5175E2E0.1030901@asianux.com>
References: <51750FC0.8000603@asianux.com> <1366659281.4016.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"dhowells@redhat.com" <dhowells@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Serge Hallyn <serge.hallyn@canonical.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:36307 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab3DWBZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 21:25:37 -0400
In-Reply-To: <1366659281.4016.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8823=E6=97=A5 03:34, Ben Hutchings wrote:
> On Mon, 2013-04-22 at 18:24 +0800, Chen Gang wrote:
>> n_elem is unsigned int which never < 0.
>>   but it seems, we realy need check it whether < 0.
>>   so need a type cast for it.
>>
>>   find it by EXTRA_CFLAGS=3D-W
>>
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> ---
>>  net/rxrpc/ar-key.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
>> index 7633a75..ba0b722 100644
>> --- a/net/rxrpc/ar-key.c
>> +++ b/net/rxrpc/ar-key.c
>> @@ -346,7 +346,7 @@ static int rxrpc_krb5_decode_tagged_array(struct=
 krb5_tagged_data **_td,
>> =20
>>  	n_elem =3D ntohl(*xdr++);
>>  	toklen -=3D 4;
>> -	if (n_elem < 0 || n_elem > max_n_elem)
>> +	if ((int)n_elem < 0 || n_elem > max_n_elem)
>=20
> (int)n_elem < 0 is equivalent to n_elem >=3D 0x80000000, and if that =
is
> true then n_elem > max_n_elem (because max_n_elem <=3D 0xff).
>=20

  ok, thanks, my subject and the comments are incorrect.

  but I still prefer to improve the original code like below.
    (also need change the subject and the comments)

----------------------diff begin---------------------------------------=
---------

diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 7633a75..cde682f 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -346,7 +346,7 @@ static int rxrpc_krb5_decode_tagged_array(struct kr=
b5_tagged_data **_td,
=20
 	n_elem =3D ntohl(*xdr++);
 	toklen -=3D 4;
-	if (n_elem < 0 || n_elem > max_n_elem)
+	if (n_elem > max_n_elem)
 		return -EINVAL;
 	*_n_elem =3D n_elem;
 	if (n_elem > 0) {

----------------------diff end-----------------------------------------=
---------

> Ben.
>=20
>>  		return -EINVAL;
>>  	*_n_elem =3D n_elem;
>>  	if (n_elem > 0) {
>=20


--=20
Chen Gang

Asianux Corporation
