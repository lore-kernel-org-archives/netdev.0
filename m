From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Unable to create more than 1 guest virtio-net device using
	vhost-net backend
Date: Sun, 21 Mar 2010 11:55:44 +0200
Message-ID: <20100321095544.GA6443@redhat.com>
References: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, avi@redhat.com,
	gleb@redhat.com
To: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993Ab0CUJ7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 05:59:12 -0400
Content-Disposition: inline
In-Reply-To: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 03:19:27PM -0700, Sridhar Samudrala wrote:
> When creating a guest with 2 virtio-net interfaces, i am running
> into a issue causing the 2nd i/f falling back to userpace virtio
> even when vhost is enabled.
> 
> After some debugging, it turned out that KVM_IOEVENTFD ioctl() 
> call in qemu is failing with ENOSPC.
> This is because of the NR_IOBUS_DEVS(6) limit in kvm_io_bus_register_dev()
> routine in the host kernel.
> 
> I think we need to increase this limit if we want to support multiple
> network interfaces using vhost-net.
> Is there an alternate solution?
> 
> Thanks
> Sridhar

Nothing easy that I can see. Each device needs 2 of these.  Avi, Gleb,
any objections to increasing the limit to say 16?  That would give us
5 more devices to the limit of 6 per guest.

-- 
MST
