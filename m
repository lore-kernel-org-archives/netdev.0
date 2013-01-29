From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] soreuseport: fix use of uid in tb->fastuid
Date: Tue, 29 Jan 2013 04:26:08 -0800
Message-ID: <87libc9nvj.fsf@xmission.com>
References: <alpine.DEB.2.00.1301260944370.27231@pokey.mtv.corp.google.com>
	<20130128074707.GN9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51905 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3A2M0S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 07:26:18 -0500
In-Reply-To: <20130128074707.GN9147@secunet.com> (Steffen Klassert's message
	of "Mon, 28 Jan 2013 08:47:07 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen Klassert <steffen.klassert@secunet.com> writes:

> On Sat, Jan 26, 2013 at 09:50:54AM -0800, Tom Herbert wrote:
>> Fix a reported compilation error where ia variable of type kuid_t
>> was being set to zero.
>>=20
>
> Thanks for fixing this.
> Unfortunately I get another compilation error now:
>
> net/ipv6/inet6_connection_sock.c: In function =E2=80=98inet6_csk_bind=
_conflict=E2=80=99:
> net/ipv6/inet6_connection_sock.c:37:12: error: incompatible types whe=
n initializing type =E2=80=98int=E2=80=99 using type =E2=80=98kuid_t=E2=
=80=99
> net/ipv6/inet6_connection_sock.c:54:30: error: incompatible type for =
argument 1 of =E2=80=98uid_eq=E2=80=99
> include/linux/uidgid.h:70:20: note: expected =E2=80=98kuid_t=E2=80=99=
 but argument is of type =E2=80=98int=E2=80=99
> make[3]: *** [net/ipv6/inet6_connection_sock.o] Error 1
>
> I wondered why noone else is seeing this, so I did some analysis.
> I'm getting this because of the UIDGID_STRICT_TYPE_CHECKS config opti=
on.
> This is selected by USER_NS which in turn depends on UIDGID_CONVERTED=
=2E
> Most people can't enable USER_NS because they compile something like
> nfs or anything else that is not 'UIDGID_CONVERTED'.

Yes.  There are currently 11 filesystems whose uid_t to kuid_t
conversions have not yet been merged.  I am working on those
conversions now and with a little luck I will have everything
ready them all converted by 3.9.

Eric
