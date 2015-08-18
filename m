From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 18 Aug 2015 18:39:17 +1000
Message-ID: <20150818183917.457b2586@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	N V V Satyanarayana Reddy <nalreddy@cisco.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/built-in.o: In function `.vnic_wq_devcmd2_alloc':
(.text+0x49fe40): multiple definition of `.vnic_wq_devcmd2_alloc'
drivers/scsi/built-in.o:(.text+0xb4318): first defined here
drivers/net/built-in.o:(.opd+0x2af00): multiple definition of `vnic_wq_devcmd2_alloc'
drivers/scsi/built-in.o:(.opd+0xad70): first defined here
drivers/net/built-in.o: In function `.vnic_wq_init_start':
(.text+0x49f9c0): multiple definition of `.vnic_wq_init_start'
drivers/scsi/built-in.o:(.text+0xb3b58): first defined here
drivers/net/built-in.o:(.opd+0x2ae88): multiple definition of `vnic_wq_init_start'
drivers/scsi/built-in.o:(.opd+0xace0): first defined here

Caused by commit

  373fb0873d43 ("enic: add devcmd2")

I have reverted that commit for today.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
