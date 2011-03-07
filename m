From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: RFC: dsa slave open handling
Date: Mon, 07 Mar 2011 20:35:47 +0100
Message-ID: <87wrkalo4s.fsf@macbook.be.48ers.dk>
References: <871v2inajz.fsf@macbook.be.48ers.dk>
	<20110307182308.GY16649@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:61551 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755130Ab1CGTfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 14:35:51 -0500
Received: by ewy6 with SMTP id 6so1649718ewy.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 11:35:50 -0800 (PST)
In-Reply-To: <20110307182308.GY16649@mail.wantstofly.org> (Lennert Buytenhek's
	message of "Mon, 7 Mar 2011 19:23:08 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Lennert" == Lennert Buytenhek <buytenh@wantstofly.org> writes:

Hi,

 >> Currently the state of the dsa master device and slave devices are not
 >> synchronized which leads to various issues. With dsa, the master device
 >> needs to be running before you can use the slave devices, but it
 >> shouldn't be used directly for I/O.

 Lennert> I think this should not be handled any differently than VLAN
 Lennert> interfaces, where eth0 needs to be up before you can exchange
 Lennert> packets over eth0.123.

 Lennert> IOW, if you want to do DHCP over wan (a DSA-tunneled interface
 Lennert> over eth0), then just use an initramfs that sets eth0 up and
 Lennert> then runs a DHCP client on wan.

True. There are a few differences between vlans and dsa devices though,
which might make us want to handle them differently:

- VLANs are configured at runtime from userspace, DSA devices are
  configured directly in kernel code (E.G platform devices) - So by
  definition you cannot use the autconfig / nfsroot stuff on VLANs as
  they are not created before userspace runs, but DSA devices are
  basically indistinguishable from "real" devices from the POV of
  userspace.

- VLANs relation to their upstream ethernet device is clearly visible
  (E.G through brctl), whereas the details about what interface a DSA
  switch is connected to isn't.

-- 
Bye, Peter Korsgaard
