From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC/HACK] net/compat/wext: allow sending different messages to compat tasks
Date: Mon, 22 Jun 2009 00:03:22 +0200
Message-ID: <200906220003.22458.arnd@arndb.de>
References: <1245589835.5003.2.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:62931 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457AbZFUWD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 18:03:29 -0400
In-Reply-To: <1245589835.5003.2.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 21 June 2009, Johannes Berg wrote:
> --- wireless-testing.orig/net/compat.c  2009-06-19 17:50:30.000000000 +0200
> +++ wireless-testing/net/compat.c       2009-06-19 17:53:13.000000000 +0200
> @@ -782,16 +782,18 @@ asmlinkage long compat_sys_socketcall(in
>                 ret = sys_socketpair(a0, a1, a[2], compat_ptr(a[3]));
>                 break;
>         case SYS_SEND:
> -               ret = sys_send(a0, compat_ptr(a1), a[2], a[3]);
> +               ret = sys_send(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT);
>                 break;
>         case SYS_SENDTO:
> -               ret = sys_sendto(a0, compat_ptr(a1), a[2], a[3], compat_ptr(a[4]), a[5]);
> +               ret = sys_sendto(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT,
> +                                compat_ptr(a[4]), a[5]);
>                 break;
>         case SYS_RECV:
> -               ret = sys_recv(a0, compat_ptr(a1), a[2], a[3]);
> +               ret = sys_recv(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT);
>                 break;
>         case SYS_RECVFROM:
> -               ret = sys_recvfrom(a0, compat_ptr(a1), a[2], a[3], compat_ptr(a[4]), compat_ptr(a[5]));
> +               ret = sys_recvfrom(a0, compat_ptr(a1), a[2], a[3] | MSG_CMSG_COMPAT,
> +                                  compat_ptr(a[4]), compat_ptr(a[5]));
>                 break;
>         case SYS_SHUTDOWN:
>                 ret = sys_shutdown(a0,a1);

I suppose if you do this, you also need to introduce a
compat_sys_{send,sendto,recv,recvfrom} entry point
for architectures that do not go through sys_socket but
call sys_{send,sendto,recv,recvfrom} directly. I think
this is only sparc and mips.

	Arnd <><
