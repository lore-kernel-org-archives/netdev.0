From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Unable to create more than 1 guest virtio-net device using
 vhost-net backend
Date: Fri, 19 Mar 2010 15:19:27 -0700
Message-ID: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:49190 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab0CSWZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 18:25:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a guest with 2 virtio-net interfaces, i am running
into a issue causing the 2nd i/f falling back to userpace virtio
even when vhost is enabled.

After some debugging, it turned out that KVM_IOEVENTFD ioctl() 
call in qemu is failing with ENOSPC.
This is because of the NR_IOBUS_DEVS(6) limit in kvm_io_bus_register_dev()
routine in the host kernel.

I think we need to increase this limit if we want to support multiple
network interfaces using vhost-net.
Is there an alternate solution?

Thanks
Sridhar


