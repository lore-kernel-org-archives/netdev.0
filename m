From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [RFC v2] net: Introduce recvmmsg socket syscall
Date: Fri, 12 Jun 2009 10:26:25 +0300
Message-ID: <200906121026.27010.remi.denis-courmont@nokia.com>
References: <20090611034022.GC22424@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Paul Moore <paul.moore@hp.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: ext Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:63594 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755329AbZFLH0m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 03:26:42 -0400
In-Reply-To: <20090611034022.GC22424@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 June 2009 06:40:22 ext Arnaldo Carvalho de Melo wrote:
> diff --git a/arch/x86/include/asm/unistd_64.h
> b/arch/x86/include/asm/unistd_64.h index 900e161..713a32a 100644
> --- a/arch/x86/include/asm/unistd_64.h
> +++ b/arch/x86/include/asm/unistd_64.h
> @@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
>  __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
>  #define __NR_perf_counter_open                 298
>  __SYSCALL(__NR_perf_counter_open, sys_perf_counter_open)
> +#define __NR_recvmmsg                          299
> +__SYSCALL(__NR_recvmmsg, sys_recvmmsg)

I guess socketcall is deprecated in favor of full syscalls, then?
(sorry if this is a stupid question)

> +       if (timeout) {
> +               /* Doesn't make much sense */
> +               if (flags & MSG_DONTWAIT)
> +                       return -EINVAL;

An application could possibly hit this degenerated case at the end of a=
 loop=20
or whatever, and EINVAL makes it look like this is a bug. Why not EAGAI=
N?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

