From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 00/14] RDS: connection scalability and performance
 improvements
Date: Thu, 1 Oct 2015 16:19:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBAA322@AcuExch.aculab.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ssantosh@kernel.org" <ssantosh@kernel.org>
To: 'Santosh Shilimkar' <santosh.shilimkar@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar
> Sent: 30 September 2015 18:24
...
> This is being addressed by simply using per bucket rw lock which makes the
> locking simple and very efficient. The hash table size is still an issue and
> I plan to address it by using re-sizable hash tables as suggested on the list.

If the hash chains are short do you need the expense of a rw lock
for each chain?
A simple spinlock may be faster.

If you use the hash chain lock for the reference count on the hashed
objects you should be able to release the lock before locking the
object itself.

	David
