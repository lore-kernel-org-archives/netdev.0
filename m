From: Tom Herbert <tom@herbertland.com>
Subject: Re: CONFIG_XPS depends on L1_CACHE_BYTES being greater than
 sizeof(struct xps_map)
Date: Thu, 22 Oct 2015 14:37:31 -0700
Message-ID: <CALx6S351U9L43Qh88DkJSM4tmhR-7SDoC6bCEhNqxnuu8LqTNA@mail.gmail.com>
References: <42430464-867C-4E0B-8E95-C6CDB6D8A0B2@bell.net>
	<32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
	<B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
	<trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
	<trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
	<1445524549.2207.1.camel@HansenPartnership.com>
	<5628F868.3040105@bell.net>
	<5629404B.8090805@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	John David Anglin <dave.anglin@bell.net>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36548 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbJVVhc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 17:37:32 -0400
Received: by ioll68 with SMTP id l68so106482032iol.3
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 14:37:31 -0700 (PDT)
In-Reply-To: <5629404B.8090805@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2015 at 1:00 PM, Helge Deller <deller@gmx.de> wrote:
> Hi Tom & David,
>
> I've queued-up a patch for the parisc architecture which reduces L1_C=
ACHE_BYTES from 32 to 16:
>   https://patchwork.kernel.org/patch/7399291/
>
> But this change will break the kernel build like this:
>
> In file included from net/core/dev.c:92:0:
> net/core/dev.c: In function =E2=80=98expand_xps_map=E2=80=99:
> include/linux/netdevice.h:721:27: warning: overflow in implicit const=
ant conversion [-Woverflow]
>    #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map=
)) \
> net/core/dev.c:1972:18: note: in expansion of macro =E2=80=98XPS_MIN_=
MAP_ALLOC=E2=80=99
>    int alloc_len =3D XPS_MIN_MAP_ALLOC;
>
> Do you see an easy way to fix this ?
>
How about

 #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - ((sizeof(struct xps_map)
% L1_CACHE_BYTES)) \

Tom

> Thanks,
> Helge
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
