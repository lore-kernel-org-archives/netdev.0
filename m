From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/22] vmxnet3: avoid format strint overflow warning
Date: Fri, 14 Jul 2017 09:04:03 -0700 (PDT)
Message-ID: <20170714.090403.1626657578346063371.davem@davemloft.net>
References: <20170714120720.906842-1-arnd@arndb.de>
        <20170714120720.906842-13-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, skhare@vmware.com,
        pv-drivers@vmware.com, gregkh@linuxfoundation.org,
        torvalds@linux-foundation.org, linux@roeck-us.net,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        jejb@linux.vnet.ibm.com, martin.petersen@oracle.com,
        linux-scsi@vger.kernel.org, x86@kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-13-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 14 Jul 2017 14:07:04 +0200

> gcc-7 notices that "-event-%d" could be more than 11 characters long
> if we had larger 'vector' numbers:
> 
> drivers/net/vmxnet3/vmxnet3_drv.c: In function 'vmxnet3_activate_dev':
> drivers/net/vmxnet3/vmxnet3_drv.c:2095:40: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
> sprintf(intr->event_msi_vector_name, "%s-event-%d",
>                                      ^~~~~~~~~~~~~
> drivers/net/vmxnet3/vmxnet3_drv.c:2095:3: note: 'sprintf' output between 9 and 33 bytes into a destination of size 32
> 
> The current code is safe, but making the string a little longer
> is harmless and lets gcc see that it's ok.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
