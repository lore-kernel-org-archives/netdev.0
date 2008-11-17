From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: Cleanup of af_unix
Date: Mon, 17 Nov 2008 20:20:29 +0100
Message-ID: <4921C3FD.106@cosmosbay.com>
References: <49210AE7.3050405@cosmosbay.com>	 <20081116.223209.239966240.davem@davemloft.net>	 <4921133D.6070800@cosmosbay.com> <1226907282.4037.31.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050607030805040208070408"
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33944 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbYKQTUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 14:20:39 -0500
In-Reply-To: <1226907282.4037.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050607030805040208070408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Joe Perches a =E9crit :
> On Mon, 2008-11-17 at 07:46 +0100, Eric Dumazet wrote:
>> [PATCH] net: Cleanup of af_unix
>>
>> This is a pure cleanup of net/unix/af_unix.c to meet current code styl=
e standards
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> ---=20
>>  net/unix/af_unix.c |  117 ++++++++++++++++++++-----------------------=

>>  1 files changed, 55 insertions(+), 62 deletions(-)
>> plain text document attachment (af_unix_cleanup.patch)
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 4a39771..58db2a2 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -354,7 +353,7 @@ static void unix_sock_destructor(struct sock *sk)
>>  	WARN_ON(!sk_unhashed(sk));
>>  	WARN_ON(sk->sk_socket);
>>  	if (!sock_flag(sk, SOCK_DEAD)) {
>> -		printk("Attempt to release alive unix socket: %p\n", sk);
>> +		printk(KERN_DEBUG "Attempt to release alive unix socket: %p\n", sk)=
;
>>  		return;
>>  	}
>> =20
>=20
> Well, perhaps not quite pure.
> The KERN_ level selection is debatable.
> This could or perhaps should be KERN_INFO.

Thanks Joe

[PATCH] net: af_unix should use KERN_INFO instead of KERN_DEBUG

As spotted by Joe Perches, we should use KERN_INFO in unix_sock_destructo=
r()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------050607030805040208070408
Content-Type: text/plain;
 name="af_unix_printk.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_unix_printk.patch"

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f2cf3f5..da3e804 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -353,7 +353,7 @@ static void unix_sock_destructor(struct sock *sk)
 	WARN_ON(!sk_unhashed(sk));
 	WARN_ON(sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk(KERN_DEBUG "Attempt to release alive unix socket: %p\n", sk);
+		printk(KERN_INFO "Attempt to release alive unix socket: %p\n", sk);
 		return;
 	}
 

--------------050607030805040208070408--
