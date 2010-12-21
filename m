From: Colin Walters <walters@verbum.org>
Subject: Re: [RFC] ipv4: add ICMP socket kind
Date: Tue, 21 Dec 2010 13:46:41 -0500
Message-ID: <AANLkTikS6rs-AFGmtTfuRdELJ5+y=o4g1i0Xk9KDFRiv@mail.gmail.com>
References: <20101221181800.GA8166@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Solar Designer <solar@openwall.com>
To: Vasiliy Kulikov <segooon@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101221181800.GA8166@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 21, 2010 at 1:18 PM, Vasiliy Kulikov <segooon@gmail.com> wr=
ote:
> Hi,
>
> This patch adds IPPROTO_ICMP socket kind. =C2=A0It makes it possible =
to send
> ICMP_ECHO messages and receive corresponding ICMP_ECHOREPLY messages
> without any special privileges. =C2=A0In other words, the patch makes=
 it
> possible to implement setuid-less /bin/ping.
>
> A new ping socket is created with
>
> =C2=A0 =C2=A0socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)

And the default is to allow any uid to do this (modulo LSM)?

If you really have a burning desire to get rid of setuid /bin/ping,
why not just do it in userspace via message passing to/from a
privileged process, and avoid a lot of code in the kernel?  It's much
more flexible.  You could, for example, limit it to once a second by
default, allow only one process doing this per uid, etc.
