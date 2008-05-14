From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 17:56:52 +0400
Message-ID: <20080514135652.GB23131@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <20080513233341.47edea7f.akpm@linux-foundation.org> <20080514074028.GA28330@2ka.mipt.ru> <20080514080801.GE28330@2ka.mipt.ru> <Pine.LNX.4.64.0805140638450.14334@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sage Weil <sage@newdream.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762418AbYENN5Y@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805140638450.14334@cobra.newdream.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 14, 2008 at 06:41:53AM -0700, Sage Weil (sage@newdream.net) wrote:
> Yes.  Only a pagevec at a time, though... apparently 14 is a small enough 
> number not to bite too many people in practice?

Well, POHMELFS can use up to 90 out of 512 or 1024 on x86, but that just
moves a problem a bit closer.

IMHO problem can be in fact, that copy can be more significant overhead
than per page sockt lock and direct DMA (I belive most of the GigE and
above (and of course RDMA) links have scatter-gather and RX checksumming),
it has to be tested, so I will change writeback path for POHMELFS to test
things. If there will not be any performance degradataion (and I believe
there will not be, as long as no improvements, since tests were always
network bound), I will use that approach.

-- 
	Evgeniy Polyakov
