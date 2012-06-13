From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/5] drivers/net/ethernet/dec/tulip: Use standard
 __set_bit_le() function
Date: Wed, 13 Jun 2012 16:14:17 +0100
Message-ID: <1339600457.2612.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
	 <20120613130304.0186fa9d.yoshikawa.takuya@oss.ntt.co.jp>
	 <CAC5umyj582T+9GbOYDzOAanmMcVZ-Fdxr7i-8GWf3gTSmtAKUA@mail.gmail.com>
	 <20120613214157.0a5179d5358ec7f1b2646606@gmail.com>
	 <CAC5umygutE35hVObuooWj=ADP6PZDy4cqLtxGnRtxRX8uTtGSw@mail.gmail.com>
	 <20120613230013.3cc59bf908616e94bb4ccef2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>,
	<akpm@linux-foundation.org>, <grundler@parisc-linux.org>,
	<arnd@arndb.de>, <benh@kernel.crashing.org>, <avi@redhat.com>,
	<mtosatti@redhat.com>, <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arch@vger.kernel.org>, <kvm@vger.kernel.org>
To: Takuya Yoshikawa <takuya.yoshikawa@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120613230013.3cc59bf908616e94bb4ccef2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-13 at 23:00 +0900, Takuya Yoshikawa wrote:
> On Wed, 13 Jun 2012 22:31:13 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 
> > >> Should this hash_table be converted from u16 hash_table[32] to
> > >> DECLARE_BITMAP(hash_table, 16 * 32) to ensure that it is aligned
> > >> on long-word boundary?
> > >
> > > I think hash_table is already long-word aligned because it is placed
> > > right after a pointer.
> > 
> > I recommend converting to proper bitmap.  Because such an implicit
> > assumption is easily broken by someone touching this function.
> 
> Do you mean something like:
> 	DECLARE_BITMAP(__hash_table, 16 * 32);
> 	u16 *hash_table = (u16 *)__hash_table;
> ?
[...]

Could this driver perhaps use:

	union hash_table {
		DECLARE_BITMAP(bits, 16 * 32);
		__le16 words[32];
	};

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
