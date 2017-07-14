From: "Burla, Satananda" <Satananda.Burla@cavium.com>
Subject: Re: [PATCH 13/22] liquidio: fix possible eeprom format string
 overflow
Date: Fri, 14 Jul 2017 15:40:09 -0700
Message-ID: <20170714224009.2537mysgwab272xp@caviumnetworks.com>
References: <20170714120720.906842-1-arnd@arndb.de>
 <20170714120720.906842-14-arnd@arndb.de>
 <20170714.090408.1884235496293241466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "arnd@arndb.de" <arnd@arndb.de>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>,
        "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "x86@kernel.org" <x86@kernel.org>,
        "Chang, Weilin" <Weilin.Chang@cavium.com>,
        "Kanneganti,
To: "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170714.090408.1884235496293241466.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 07/14/2017 09:04, David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Fri, 14 Jul 2017 14:07:05 +0200
> 
> > gcc reports that the temporary buffer for computing the
> > string length may be too small here:
> >
> > drivers/net/ethernet/cavium/liquidio/lio_ethtool.c: In function
> 'lio_get_eeprom_len':
> > /drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:345:21: error: 'sprintf'
> may write a terminating nul past the end of the destination [-Werror=
> format-overflow=]
> >   len = sprintf(buf, "boardname:%s serialnum:%s maj:%lld min:%lld\n",
> >                      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:345:6: note: 'sprintf'
> output between 35 and 167 bytes into a destination of size 128
> >   len = sprintf(buf, "boardname:%s serialnum:%s maj:%lld min:%lld\n",
> >
> > This extends it to 192 bytes, which is certainly enough. As far
> > as I could tell, there are no other constraints that require a specific
> > maximum size.
> >
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Applied.
I had raised a bug for this earlier and attached a patch as well. 

http://cabugzilla1.caveonetworks.com/octeon_bugzilla/show_bug.cgi?id=26421


-- 
Regards
Satanand
