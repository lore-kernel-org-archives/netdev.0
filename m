From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH netdev-2.6 7/10] ixgb: Replace kmalloc with vmalloc to allocate driver local data structures
Date: Fri, 29 Oct 2004 11:29:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029182926.GF12934@holomorphy.com>
References: <468F3FDA28AA87429AD807992E22D07E0312853C@orsmsx408> <20041029130817.GA12301@infradead.org> <418277B7.7000705@pobox.com> <20041029173636.GB12934@holomorphy.com> <41828B5D.7090908@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        netdev <netdev@oss.sgi.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41828B5D.7090908@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

William Lee Irwin III wrote:
>> vmalloc is relatively highly penalized. For instance, global TLB
>> flushes associated with vfree() and so on. Aggregate vmallocspace
>> limitations are a big concern. I probably wouldn't use vmallocspace
>> for much besides infrequent allocations, e.g. things allocated during
>> driver initialization. One per driver instance won't really hurt much
>> because vmallocspace limits prevent large numbers of drivers from being
>> simultaneously loaded as it stands now anyway.

On Fri, Oct 29, 2004 at 02:26:37PM -0400, Jeff Garzik wrote:
> That's precisely what we're contemplating -- a once per driver 
> allocation that remains static for the entire driver runtime (descriptors)

An infrastructural change that does this would probably need to be
considered more carefully. I think you can probably just do it.


-- wli
