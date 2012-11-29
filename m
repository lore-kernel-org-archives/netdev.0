From: Peter Lieven <pl@dlhnet.de>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Thu, 29 Nov 2012 19:58:19 +0100
Message-ID: <50B7B04B.2010504@dlhnet.de>
References: <50AE36E0.8000307@dlhnet.de> <20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
	netdev@vger.kernel.org, mst@redhat.com
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ssl.dlhnet.de ([91.198.192.8]:59284 "EHLO ssl.dlh.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab2K2S6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 13:58:25 -0500
In-Reply-To: <20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.11.2012 08:02, schrieb Stefan Hajnoczi:
> On Thu, Nov 22, 2012 at 03:29:52PM +0100, Peter Lieven wrote:
>> is anyone aware of a problem with the linux network bridge that in very rare circumstances stops
>> a bridge from sending pakets to a tap device?
>>
>> My problem occurs in conjunction with vanilla qemu-kvm-1.2.0 and Ubuntu Kernel 3.2.0-34.53
>> which is based on Linux 3.2.33.
>>
>> I was not yet able to reproduce the issue, it happens in really rare cases. The symptom is that
>> the tap does not have any TX packets. RX is working fine. I see the packets coming in at
>> the physical interface on the host, but they are not forwarded to the tap interface.
>> The bridge itself has learnt the mac address of the vServer that is connected to the tap interface.
>> It does not help to toggle the bridge link status,  the tap interface status or the interface in the vServer.
>> It seems that problem occurs if a tap interface that has previously been used, but set to nonpersistent
>> is set persistent again and then is by chance assigned to the same vServer (=same mac address on same
>> bridge) again. Unfortunately it seems not to be reproducible.
> 
> Not sure but this patch from Michael Tsirkin may help - it solves an
> issue with persistent tap devices:
> 
> http://patchwork.ozlabs.org/patch/198598/

I have tried that patch (even if I do not use persistant taps), but it doesn't help.

What I can say now is that if a VM is not working with a tap - lets say tap10 then
it will not work with tap10, even if the vm is shut down. tap10 is set to non-persistant.
then the vm is started again, assigned occasionally again tap10 and is not working again.

BUT, if I use qemu-kvm-1.0.1 in the second case it is working. I have seen that there is
a lot of changes between 1.0.1 and 1.2.0 in the tap code. Maybe there is a bug in the
inititialization since then.

What also seem to have changed is that vlans have been removed. I was not aware of that,
so I still use vlans which are now emulated via hubs. Maybe this is related.

Peter

> 
> Stefan
> 
