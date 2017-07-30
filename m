From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid bogus gcc-7 array-bounds warning
Date: Sat, 29 Jul 2017 23:27:43 -0700 (PDT)
Message-ID: <20170729.232743.2176188817187533294.davem@davemloft.net>
References: <20170728144153.2024234-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, edumazet@google.com,
        ncardwell@google.com, soheil@google.com, ycheng@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47700 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753561AbdG3G1q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 02:27:46 -0400
In-Reply-To: <20170728144153.2024234-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 28 Jul 2017 16:41:37 +0200

> When using CONFIG_UBSAN_SANITIZE_ALL, the TCP code produces a
> false-positive warning:
> 
> net/ipv4/tcp_output.c: In function 'tcp_connect':
> net/ipv4/tcp_output.c:2207:40: error: array subscript is below array bounds [-Werror=array-bounds]
>    tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
>                                         ^~
> net/ipv4/tcp_output.c:2207:40: error: array subscript is below array bounds [-Werror=array-bounds]
>    tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
>    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~
> 
> I have opened a gcc bug for this, but distros have already shipped
> compilers with this problem, and it's not clear yet whether there is
> a way for gcc to avoid the warning. As the problem is related to the
> bitfield access, this introduces a temporary variable to store the old
> enum value.
> 
> I did not notice this warning earlier, since UBSAN is disabled when
> building with COMPILE_TEST, and that was always turned on in both
> allmodconfig and randconfig tests.
> 
> Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81601
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
