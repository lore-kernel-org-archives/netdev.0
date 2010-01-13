From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: tcp_header_len_th and tcp_option_len_th
Date: Wed, 13 Jan 2010 11:00:16 +0100
Message-ID: <4B4D99B0.8090102@gmail.com>
References: <4B44FE3C.6060809@gmail.com> <4B450065.4010108@gmail.com> <4B4C519E.2090207@gmail.com> <4B4CB46C.8020502@gmail.com> <4B4CB712.8030806@gmail.com> <4B4D8A24.4070108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755283Ab0AMKAX@vger.kernel.org>
In-Reply-To: <4B4D8A24.4070108@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/01/2010 09:53, William Allen Simpson a =E9crit :
> Eric Dumazet wrote:
>=20
>> About cast games, maybe following way is the cleanest one.
>>
>> int tcp_options_len_th(struct tcphdr *th)
>> {
>>     return tcp_header_len_th(th) - sizeof(*th);
>> }
>>
> If you'd have been one of my C students, you'd have failed the exam
> question.  That's unsigned int tcp_header_len_th() -- subtracting an
> untyped constant could be a negative number (stored in an unsigned).
> Then demotion to int (which many compilers truncate to a very large
> positive number).

Thats simply not true, you are very confused.

Once again you type too much text and ignore my comments.
I really would hate being your student, thanks God it wont happen in th=
is life.

1) You wrote tcp_header_len_th(), you should know that it
returns an unsigned int.

2) You also should know that sizeof() is *strongly* typed (size_t),
not an "untyped constant".

unsigned int arg =3D some_expression;
size_t sz =3D sizeof(something)
int res =3D arg - sz;
return res;

is *perfectly* legal and very well defined by C standards.

It *will* return a negative value is arg < sz



>=20
> It's one of the reasons that folks used to do all this with macros, s=
o
> that the types and truncation were handled well by the compiler.
>=20
> Of course, this is an inline function, which is more like macros.  I'=
ve
> not studied how gcc works internally since egcs.
>=20
> Let's keep (int)(th->doff * 4) - sizeof(*th) -- self documenting, and
> should work with a wide variety of compilers.

So you wrote tcp_header_len_th(), but you keep (th->doff * 4) thing all=
 over
the code...

The (int) cast it not only _not_ needed, its also confusing.
