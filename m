From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 14:31:10 +0100
Message-ID: <4AEEDF1E.3090204@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com> <4AEDDF33.9030205@gmail.com> <4AEECFA8.1080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54983 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183AbZKBNbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 08:31:08 -0500
In-Reply-To: <4AEECFA8.1080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Eric Dumazet wrote:
>> This part is really hard to review, and might be splitted ?
>>
>> cleanups could be done in a cleanup patch only
>>
>> Examples:
>>
>> -    tmp_opt.mss_clamp =3D 536;
>> -    tmp_opt.user_mss  =3D tcp_sk(sk)->rx_opt.user_mss;
>> +    tmp_opt.mss_clamp =3D TCP_MIN_RCVMSS;
>> +    tmp_opt.user_mss  =3D tp->rx_opt.user_mss;
>>
>>
>> -    tp->mss_cache =3D 536;
>> +    tp->mss_cache =3D TCP_MIN_RCVMSS;
>>
> Often hard to decide what's "cleanup" and what's essential.  I'll loo=
k at
> that again for the next round, but I've already split the original si=
ngle
> patch into multiple parts.

cleanups are trivial, and should be separated from functionnal changes.

>=20
>=20
>> Also your tests are reversed, if you look at the existing coding sty=
le.
>>
> I checked Documentation/CodingStyle, and that's not specified.  I've =
seen
> plenty of examples of modern security coding style around here.
>=20
> As a long-time (25+ years) consultant and 30 years C programmer, I'm
> heedful of the project coding style, and had to endure many variants.
>=20
> Where I'm working with others' code, you'll note that I keep the same
> style, no matter how ugly, as that makes patches easier to read.
>=20
>=20
>> Example :
>>
>> +    /* TCP Cookie Transactions */
>> +    if (0 < sysctl_tcp_cookie_size) {
>> +        /* Default, cookies without s_data. */
>> +        tp->cookie_values =3D
>> +            kzalloc(sizeof(*tp->cookie_values),
>> +                sk->sk_allocation);
>> +        if (NULL !=3D tp->cookie_values)
>> +            kref_init(&tp->cookie_values->kref);
>> +    }
>>
>> should be ->
>>
>> +    /* TCP Cookie Transactions */
>> +    if (sysctl_tcp_cookie_size > 0) {
>> +        /* Default, cookies without s_data. */
>> +        tp->cookie_values =3D
>> +            kzalloc(sizeof(*tp->cookie_values),
>> +                sk->sk_allocation);
>> +        if (tp->cookie_values !=3D NULL)
>> +            kref_init(&tp->cookie_values->kref);
>> +    }
>>
> And "tp->cookie_values !=3D NULL" is egregiously poor C practice.  It=
's very
> hard for code review to ensure that didn't get truncated to "=3D NULL=
".  The
> important visual element is the NULL, not the variable name.

Maybe, but check in linux source code and you'll see this poor pratice =
is the facto.
Dont try to change our minds, because it wont happen.

>=20
> Also, avoid "!tp->cookie_values", as this is *not* a boolean.

Oh, good to learn that ! operator only applies to boolean. I didnt know=
 that.

>=20
> When I'm adding new code, I use constant-to-the-left security coding =
style,
> as they teach in modern universities (lately also for PHP).  And this=
 is a
> security extension, so a security style is particularly appropriate.
>=20
> As in switch statements, constant-to-the-left makes the value obvious=
,
> especially in a series (and assists transforming if series into a swi=
tch).
>=20
> For complex tests, this makes the code much more readable and easier =
to
> visually verify on code walk-through:
>=20
> +    if (0 < tmp_opt.cookie_plus
> +     && tmp_opt.saw_tstamp
> +     && !tp->cookie_out_never
> +     && (0 < sysctl_tcp_cookie_size
> +      || (NULL !=3D tp->cookie_values
> +       && 0 < tp->cookie_values->cookie_desired))) {
>=20
> Consistent use of security style would have obviated a lot of foolish=
 >=3D 0
> tests that seem to be constantly in need of fixing.  It's a bad idea =
to
> depend on the compiler to catch non-executable code.

You can _talk_, I can stop reviewing your patches, and wait another gen=
tle guy do the job,
because I am 30 years experimented (and tired ?) programmer, and dont w=
ant to
lose my time to discuss Coding-Style with you ?

Cooking patches to linux is not only matter of good ideas and programmi=
ng (and Dropping
patches for the masses).

Its also a matter of convincing _people_ that your additions will be ma=
intainable
when you leave kernel programming and let people like us correct bugs.

=46or the moment, I am not convinced at all. I prefer to talk now.


Note: I did read your TCPCT 25 pages documentation and very am interest=
ed by this
improvement, but its _also_ important to implement it in the normal way=
=2E
(I wish this document could be public in a RFC form)

