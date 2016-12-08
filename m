From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [PATCH] linux/types.h: enable endian checks for all sparse builds
Date: Thu, 8 Dec 2016 06:38:11 +0000
Message-ID: <BLUPR02MB168304F8FBA50C916A6A4E6081840@BLUPR02MB1683.namprd02.prod.outlook.com>
References: <1481164052-28036-1-git-send-email-mst@redhat.com>
 <BLUPR02MB168374E98A6C86E43DF0BCFE81840@BLUPR02MB1683.namprd02.prod.outlook.com>
 <20161208075152-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Linus Torvalds" <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Jason Wang <jasowang@redhat.com>,
        "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>,
        Michal Marek <mmarek@suse.com>, Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Matt Mackall <mpm@selenic.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Airlie <airlied@linux.ie>,
        Gerd Hoffmann <kraxel@redhat.com>,
        Ohad Ben-Cohen <ohad@wizery.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Cornelia Huck <cornelia.huck@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>, Jens Axboe <axboe@fb.com>,
        Neil Armstrong <narmstr
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/07/16 21:54, Michael S. Tsirkin wrote:=0A=
> On Thu, Dec 08, 2016 at 05:21:47AM +0000, Bart Van Assche wrote:=0A=
>> Additionally, there are notable exceptions to the rule that most drivers=
=0A=
>> are endian-clean, e.g. drivers/scsi/qla2xxx. I would appreciate it if it=
=0A=
>> would remain possible to check such drivers with sparse without enabling=
=0A=
>> endianness checks. Have you considered to change #ifdef __CHECK_ENDIAN__=
=0A=
>> into e.g. #ifndef __DONT_CHECK_ENDIAN__?=0A=
>=0A=
> The right thing is probably just to fix these, isn't it?=0A=
> Until then, why not just ignore the warnings?=0A=
=0A=
Neither option is realistic. With endian-checking enabled the qla2xxx =0A=
driver triggers so many warnings that it becomes a real challenge to =0A=
filter the non-endian warnings out manually:=0A=
=0A=
$ for f in "" CF=3D-D__CHECK_ENDIAN__; do make M=3Ddrivers/scsi/qla2xxx C=
=3D2\=0A=
     $f | &grep -c ': warning:'; done=0A=
4=0A=
752=0A=
=0A=
If you think it would be easy to fix the endian warnings triggered by =0A=
the qla2xxx driver, you are welcome to try to fix these.=0A=
=0A=
Bart.=0A=
