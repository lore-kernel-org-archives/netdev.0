From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 10:36:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029173636.GB12934@holomorphy.com>
References: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408> <20041029130817.GA12301@infradead.org> <418277B7.7000705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <418277B7.7000705@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 29, 2004 at 05:50:45AM -0700, Venkatesan, Ganesh wrote:
>>> This is a trade-off between space allocated via kmalloc and vmalloc. My
>>> understanding is that kmalloc space is more limited than vmalloc. Is
>>> this incorrect?

Christoph Hellwig wrote:
>> Yes. kmalloc space is only limited by the amount of free memory you have
>> in your system, vmalloc has very low absolute limits (down to 64MB in
>> some configurations)..

On Fri, Oct 29, 2004 at 01:02:47PM -0400, Jeff Garzik wrote:
> However, kmalloc() has much lower per-call limits than vmalloc().
> I'm interested to see a VM person weigh in on this...
> Drivers are certainly allowed to use vmalloc.

vmalloc is relatively highly penalized. For instance, global TLB
flushes associated with vfree() and so on. Aggregate vmallocspace
limitations are a big concern. I probably wouldn't use vmallocspace
for much besides infrequent allocations, e.g. things allocated during
driver initialization. One per driver instance won't really hurt much
because vmallocspace limits prevent large numbers of drivers from being
simultaneously loaded as it stands now anyway.


-- wli
