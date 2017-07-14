From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/22] net: niu: fix format string overflow warning:
Date: Fri, 14 Jul 2017 09:03:40 -0700 (PDT)
Message-ID: <20170714.090340.81439675812003295.davem@davemloft.net>
References: <20170714120720.906842-1-arnd@arndb.de>
        <20170714120720.906842-10-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, tremyfr@gmail.com,
        gregkh@linuxfoundation.org, torvalds@linux-foundation.org,
        linux@roeck-us.net, akpm@linux-foundation.org,
        netdev@vger.kernel.org, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, linux-scsi@vger.kernel.org,
        x86@kernel.org, edumazet@google.com, stephen@networkplumber.org,
        jarod@redhat.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-10-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 14 Jul 2017 14:07:01 +0200

> We get a warning for the port_name string that might be longer than
> six characters if we had more than 10 ports:
> 
> drivers/net/ethernet/sun/niu.c: In function 'niu_put_parent':
> drivers/net/ethernet/sun/niu.c:9563:21: error: '%d' directive writing between 1 and 3 bytes into a region of size 2 [-Werror=format-overflow=]
>   sprintf(port_name, "port%d", port);
>                      ^~~~~~~~
> drivers/net/ethernet/sun/niu.c:9563:21: note: directive argument in the range [0, 255]
> drivers/net/ethernet/sun/niu.c:9563:2: note: 'sprintf' output between 6 and 8 bytes into a destination of size 6
>   sprintf(port_name, "port%d", port);
>   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/sun/niu.c: In function 'niu_pci_init_one':
> drivers/net/ethernet/sun/niu.c:9538:22: error: '%d' directive writing between 1 and 3 bytes into a region of size 2 [-Werror=format-overflow=]
>    sprintf(port_name, "port%d", port);
>                       ^~~~~~~~
> drivers/net/ethernet/sun/niu.c:9538:22: note: directive argument in the range [0, 255]
> drivers/net/ethernet/sun/niu.c:9538:3: note: 'sprintf' output between 6 and 8 bytes into a destination of size 6
> 
> While we know that the port number is small, there is no harm in
> making the format string two bytes longer to avoid the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
