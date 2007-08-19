From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
	PS_TCPportsfrom the host TCP port space.
Date: Sun, 19 Aug 2007 16:12:06 -0700 (PDT)
Message-ID: <20070819.161206.94555994.davem@davemloft.net>
References: <20070819.123212.13769462.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334018E209C@maui.asicdesigners.com>
	<p73hcmv14wo.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: andi@firstfloor.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <p73hcmv14wo.fsf@bingen.suse.de>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: 20 Aug 2007 01:27:35 +0200

> "Felix Marti" <felix@chelsio.com> writes:
> 
> > what benefits does the TSO infrastructure give the
> > non-TSO capable devices?
> 
> It improves performance on software queueing devices between guests
> and hypervisors. This is a more and more important application these
> days.  Even when the system running the Hypervisor has a non TSO
> capable device in the end it'll still save CPU cycles this way. Right now
> virtualized IO tends to much more CPU intensive than direct IO so any
> help it can get is beneficial.
> 
> It also makes loopback faster, although given that's probably not that
> useful.
> 
> And a lot of the "TSO infrastructure" was needed for zero copy TX anyways,
> which benefits most reasonable modern NICs (anything with hardware 
> checksumming)

And also, you can enable TSO generation for a non-TSO-hw device and
get all of the segmentation overhead reduction gains which works out
as a pure win as long as the device can at a minimum do checksumming.
