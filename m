From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 04/22] scsi: fusion: fix string overflow warning
Date: Mon, 17 Jul 2017 09:17:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD003A6C7@AcuExch.aculab.com>
References: <20170714120720.906842-1-arnd@arndb.de>
 <20170714120720.906842-5-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>, Helge Deller <deller@gmx.de>,
        "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>
To: 'Arnd Bergmann' <arnd@arndb.de>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        Chaitra P B <chaitra.basappa@broadcom.com>,
        Suganath Prabu Subramani
        <suganath-prabu.subramani@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-5-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> Sent: 14 July 2017 13:07
> gcc points out a theorerical string overflow:
> 
> drivers/message/fusion/mptbase.c: In function 'mpt_detach':
> drivers/message/fusion/mptbase.c:2103:17: error: '%s' directive writing up to 31 bytes into a region
> of size 28 [-Werror=format-overflow=]
> sprintf(pname, MPT_PROCFS_MPTBASEDIR "/%s/summary", ioc->name);
>                ^~~~~
> drivers/message/fusion/mptbase.c:2103:2: note: 'sprintf' output between 13 and 44 bytes into a
> destination of size 32
> 
> We can simply double the size of the local buffer here to be on the
> safe side.

I think I'd change it to snprintf() as well.
Saves any worries if ioc->name isn't '\0' terminated.

	David
