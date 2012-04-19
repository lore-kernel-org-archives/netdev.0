From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Thu, 19 Apr 2012 22:33:03 +1200
Message-ID: <CAKgNAkjZ31JAs0XFutnAozCAcHHAq6pcCAKeDNHccKQ+6uTP6g@mail.gmail.com>
References: <4F8D497F.8060601@gmail.com> <20120417.223614.629911246108750471.davem@davemloft.net>
 <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
 <20120418.001650.1042781402985153056.davem@davemloft.net> <CAKgNAkh46EMDWpessyi0n-EyNoRid-iW1O1RfUpTtzKDv0mZFw@mail.gmail.com>
 <20120419111909.616bef70@pyramind.ukuu.org.uk>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org,
	jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120419111909.616bef70-38n7/U1jhRXW96NNrWNlrekiAK3p4hvP@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 19, 2012 at 10:19 PM, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org> w=
rote:
>> 3. Considering these two sets:
>>
>> =A0 (a) [applications that rely on the assumption that there
>> =A0 =A0 =A0 =A0is a null terminator inside sizeof(sun_path) bytes]
>> =A0 (b) [applications that would break if the kernel behavior change=
d]
>>
>> =A0 I suspect that set (a) is rather larger than set (b)--or, more
>> =A0 likely still, applications ensure they go for the lowest common
>> =A0 denominator limit of 92 (HP-UX) or 104 (historical BSD limit)
>> =A0 bytes, and so avoid this issue completely.
>
> Or another way of putting it
>
> 3(a) =A0 =A0Sloppy coding that may have lots of other bugs
>
> 3(b) =A0 =A0Interfaces and code we promised not to break.

Yes, it's another way of putting it. (Though regarding 3(b), part of
the problem is that there never was a clearly specified contract.)

Anyway, I've dug deeper, looking at hat happens on other platforms.
It's a mess: the BSDs don't even guarantee  that sun_path is
null_terminated. So, here's how one has to portably deal with the
variations:

addrlen =3D sizeof(struct sockaddr_un);
cfd =3D accept(lfd, &addr, &addlen);

printf("%.*s", addrlen - offsetof(struct sockaddr_un, sun_path), addr.s=
un_path);

That's pretty hideous!

Thanks,

Michael


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
