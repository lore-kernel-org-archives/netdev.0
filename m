From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] rhashtable: Lower/upper bucket may map to same
 lock while shrinking
Date: Tue, 13 Jan 2015 15:00:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC6946@AcuExch.aculab.com>
References: <20150112232217.GA5277@wfg-t540p.sh.intel.com>
 <20150112235821.GB16617@casper.infradead.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CAC6593@AcuExch.aculab.com>
 <20150113112507.GH20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>, LKP <lkp@01.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Thomas Graf' <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150113112507.GH20387@casper.infradead.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf
...
> > Thought, could the shrunk table use the same locks as the lower half
> > of the old table?
> 
> No. A new bucket table and thus a new set of locks is allocated when the
> table is shrunk or grown. We only have check for overlapping locks
> when holding multiple locks for the same table at the same time.

I was guessing that when locks are shared buckets k and 2^n+k use the
same lock.
Under those conditions if the 'grow' decided not to allocate extra
locks then it could save work by using exactly the same locks as the
old table.
Similarly 'shrink' could do the reverse.

It was only a thought.

	David
