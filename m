From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: remove duplicate #include
Date: Thu, 29 Oct 2009 06:35:35 -0700
Message-ID: <8B1F619C9F5F454E81D90D3C161698D7017DFAA30F@EXCH-MBX-3.vmware.com>
References: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
	<20091028.222901.187567993.davem@davemloft.net>
 <20091028.225217.78322944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:44523 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752139AbZJ2Nfc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 09:35:32 -0400
In-Reply-To: <20091028.225217.78322944.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller <davem@davemloft.net>
> Date: Wed, 28 Oct 2009 22:29:01 -0700 (PDT)
> 
> > From: Shreyas Bhatewara <sbhatewara@vmware.com>
> > Date: Wed, 28 Oct 2009 09:30:40 -0700 (PDT)
> >
> >>
> >> Remove duplicate headerfile includes from vmxnet3_int.h
> >>
> >> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> >> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
> >> Signed-off-by: Bhavesh Davda <davda@vmware.com>
> >
> > Applied.
> 
> Guys, I'd like to remove the X86 Kconfig requirement for this
> driver.  There really isn't any x86 specific code in the
> driver, it uses only standard PCI and networking APIs to function.
> 
> I know the virtual hardware won't be seen on other platforms,
> but allowing the driver to get build tested on non-x86 platforms
> helps me a lot.  I do all of my build verifications on sparc64
> for example.

The driver shares in-memory data structures with the device emulation in the hypervisor, so in the VMware case since they are both on x86, we don't need any cpu_to_le32 or le32_to_cpu's when accessing them. But for correctness, if you were to compile the vmxnet3 driver for a big-endian architecture like sparc64, we will need to sprinkle those around all accesses to the shared data structures.

In other words, don't just trivially remove the X86 Kconfig requirement for this driver.

Thanks

- Bhavesh
