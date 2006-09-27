From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED] cls_basic: Use unsigned int when generating handle
Date: Wed, 27 Sep 2006 11:33:01 +0200
Message-ID: <20060927093301.GY18349@postel.suug.ch>
References: <20060926183621.GX18349@postel.suug.ch> <Pine.LNX.4.44.0609271104470.9010-100000@dhcp09282.ntc.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:27842 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965458AbWI0Jck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 05:32:40 -0400
To: "Nordlund Kim (Nokia-NET/Helsinki)" <Kim.Nordlund@nokia.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0609271104470.9010-100000@dhcp09282.ntc.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Nordlund Kim (Nokia-NET/Helsinki) <Kim.Nordlund@nokia.com> 2006-09-27 11:50
> basic_change() won't work without this patch if we compile the
> kernel with the GCC version in RHEL5...
> 
> gcc version 4.1.1 20060817 (Red Hat 4.1.1-18)
> 
> which optimizes the code like this (objdump -S inttest.c) ...
> 
> int main()
> {
>    0:   55                      push   %ebp
>    1:   89 e5                   mov    %esp,%ebp
>   int i = 0x80000000;
>   do {
>     printf(KERN_ERR "in do %d\n", i);
>    3:   68 00 00 00 80          push   $0x80000000
>    8:   68 00 00 00 00          push   $0x0
>    d:   e8 fc ff ff ff          call   e <main+0xe>
>   } while (--i > 0);
>   printf(KERN_ERR "out of do %d\n", i);
>   12:   68 00 00 00 80          push   $0x80000000
>   17:   68 0a 00 00 00          push   $0xa
>   1c:   e8 fc ff ff ff          call   1d <main+0x1d>
>   return 0;
> }
>   21:   31 c0                   xor    %eax,%eax
>   23:   c9                      leave
>   24:   c3                      ret
> 
> # ./inttest
> in do -2147483648
> out of do -2147483648

Very interesting, naturally I tried the same after Patrick's
comment but gcc 20060901 produced code as expected, thus
staying in the loop. But now after specifying -Os gcc seems
to turn on some optimziation which produces the same code as
above.

I'm not sure I understand this optimization :-)

> So I would suggest to apply this patch to be compatible with the
> GCC version in RHEL5, and simply to make code clearer (to the
> intended idea).

Yes.
