From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] net: Add socket() system call self test.
Date: Wed, 20 Mar 2013 09:12:09 +1100
Message-ID: <CAGRGNgU4nyDrbbN6QWh06PknACP9+h2sFrRcNyOLU_pnwMU5EA@mail.gmail.com>
References: <20130319.145258.1891905092469394685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:50991 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964950Ab3CSWMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:12:31 -0400
In-Reply-To: <20130319.145258.1891905092469394685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Mar 20, 2013 at 5:52 AM, David Miller <davem@davemloft.net> wrote:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> As mentioned during the netfilter workshop, we will be adding
> all sorts of networking tests now that 3.9.x has a selftest
> framework in place.
>
> The first test I'm adding to net-next does some very simple
> testing of the socket() system call.
>
> Feel free to send patches for more tests, making the run
> script more powerful (perhaps by taking a whitespace
> seperated list of tests to run on the command line), and
> adding more checks to the socket.c test.
>
> Thanks.
>
>  tools/testing/selftests/Makefile                   |  1 +
>  tools/testing/selftests/net-socket/Makefile        | 16 ++++
>  .../testing/selftests/net-socket/run_netsocktests  | 12 +++
>  tools/testing/selftests/net-socket/socket.c        | 92 ++++++++++++++++++++++
>  4 files changed, 121 insertions(+)
>  create mode 100644 tools/testing/selftests/net-socket/Makefile
>  create mode 100644 tools/testing/selftests/net-socket/run_netsocktests
>  create mode 100644 tools/testing/selftests/net-socket/socket.c
>
> diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
> index 3cc0ad7..7c6280f 100644
> --- a/tools/testing/selftests/Makefile
> +++ b/tools/testing/selftests/Makefile
> @@ -5,6 +5,7 @@ TARGETS += vm
>  TARGETS += cpu-hotplug
>  TARGETS += memory-hotplug
>  TARGETS += efivarfs
> +TARGETS += net-socket
>
>  all:
>         for TARGET in $(TARGETS); do \
> diff --git a/tools/testing/selftests/net-socket/Makefile b/tools/testing/selftests/net-socket/Makefile
> new file mode 100644
> index 0000000..f27ee10
> --- /dev/null
> +++ b/tools/testing/selftests/net-socket/Makefile
> @@ -0,0 +1,16 @@
> +# Makefile for net-socket selftests
> +
> +CC = $(CROSS_COMPILE)gcc
> +CFLAGS = -Wall
> +
> +NET_SOCK_PROGS = socket
> +
> +all: $(NET_SOCK_PROGS)
> +%: %.c
> +       $(CC) $(CFLAGS) -o $@ $^
> +
> +run_tests: all
> +       @/bin/sh ./run_netsocktests || echo "vmtests: [FAIL]"

Should that not be "vmtests"?

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
