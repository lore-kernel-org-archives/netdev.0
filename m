From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH] net: Add socket() system call self test.
Date: Wed, 20 Mar 2013 00:14:05 +0200
Message-ID: <CAEnQRZDOwE592qXK0h-u1B7R-9oWP1CZ2rbt197QTn4oagdwgw@mail.gmail.com>
References: <20130319.145258.1891905092469394685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130319.145258.1891905092469394685.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Tue, Mar 19, 2013 at 8:52 PM, David Miller <davem@davemloft.net> wrote:
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
> +
> +clean:
> +       $(RM) $(NET_SOCK_PROGS)
> diff --git a/tools/testing/selftests/net-socket/run_netsocktests b/tools/testing/selftests/net-socket/run_netsocktests

I think it's better to have a selftests/net directory dedicated for
networking tests. Over time
the number of net-{x} directories may become very large.


Daniel.
