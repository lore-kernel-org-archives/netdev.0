From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, net] isdn: kcapi: avoid uninitialized data
Date: Tue, 28 Mar 2017 17:59:44 -0700 (PDT)
Message-ID: <20170328.175944.544884009543869614.davem@davemloft.net>
References: <20170328101120.4086874-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, mingo@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328101120.4086874-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 28 Mar 2017 12:11:07 +0200

> gcc-7 points out that the AVMB1_ADDCARD ioctl results in an unintialized
> value ending up in the cardnr parameter:
> 
> drivers/isdn/capi/kcapi.c: In function 'old_capi_manufacturer':
> drivers/isdn/capi/kcapi.c:1042:24: error: 'cdef.cardnr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>    cparams.cardnr = cdef.cardnr;
> 
> This has been broken since before the start of the git history, so
> either the value is not used for anything important, or the ioctl
> command doesn't get called in practice.
> 
> Setting the cardnr to zero avoids the warning and makes sure
> we have consistent behavior.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
