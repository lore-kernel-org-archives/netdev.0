From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen/xenbus: Use 'void' instead of 'int' for
 the return of xenbus_switch_state()
Date: Mon, 29 Sep 2014 09:41:51 +0100
Message-ID: <20140929084102.GE28628@zion.uk.xensource.com>
References: <5425961A.5000604@gmail.com>
 <5425AB57.8040804@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chen Gang <gang.chen.5i5j@gmail.com>, <konrad.wilk@oracle.com>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<boris.ostrovsky@oracle.com>, <bhelgaas@google.com>,
	<jgross@suse.com>, <yongjun_wei@trendmicro.com.cn>,
	<mukesh.rathor@oracle.com>, <xen-devel@lists.xenproject.org>,
	<linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5425AB57.8040804@citrix.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 07:07:19PM +0100, David Vrabel wrote:
> On 26/09/14 17:36, Chen Gang wrote:
> > When xenbus_switch_state() fails, it will call xenbus_switch_fatal()
> > internally, so need not return any status value, then use 'void' instead
> > of 'int' for xenbus_switch_state() and __xenbus_switch_state().
> > 
> > Also need be sure that all callers which check the return value must let
> > 'err' be 0.
> 
> I've rewritten the commit message as:
> 
>     xen/xenbus: don't return errors from xenbus_switch_state()
> 
>     Most users of xenbus_switch_state() weren't handling the failure of
>     xenbus_switch_state() correctly.  They either called
>     xenbus_dev_fatal() (which xenbus_switch_state() has effectively
>     already tried to do), or ignored errors.
> 
>     xenbus_switch_state() may fail because:
> 
>     a) The device is being unplugged by the toolstack. The device will
>     shortly be removed and the error does not need to be handled.
> 
>     b) Xenstore is broken.  There isn't much the driver can do in this
>     case since xenstore is required to signal failure to the toolstack.
> 
>     So, don't report any errors from xenbus_switch_state() which removes
>     some unnecessary error handling in some of the drivers.
> 
> I'd appreciate a review from some of the other front/backend driver
> maintainers on whether this is sensible reasoning.
> 

Looks reasonable to me.

Wei.
