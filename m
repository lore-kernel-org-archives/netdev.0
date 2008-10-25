From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [PCI] move ICHx GbE NVM write-protection from e1000e
 to PCI quirk
Date: Fri, 24 Oct 2008 22:22:54 -0400
Message-ID: <490282FE.9040602@garzik.org>
References: <20081025011358.9975.77556.stgit@gitlost.lost> <9929d2390810241827o4b0f525dt1e34b4f17ddad4a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, jbarnes@virtuousgeek.org,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59591 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751256AbYJYCXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 22:23:25 -0400
In-Reply-To: <9929d2390810241827o4b0f525dt1e34b4f17ddad4a6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> On Fri, Oct 24, 2008 at 6:13 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> The write-protection method being in the driver probe routine is called
>> late in the boot sequence, and not at all if the driver is never loaded.
>> By making it a PCI quirk the NVM is protected much earlier whether or not
>> the driver is loaded.  The write-protection quirk can be disabled with a
>> new kernel parameter in the unlikely event the NVM needs to be modified.
>>
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>
>>  Documentation/kernel-parameters.txt |    4 +
>>  drivers/net/Makefile                |    1
>>  drivers/net/e1000e/Makefile         |    1
>>  drivers/net/e1000e/e1000.h          |    1
>>  drivers/net/e1000e/ethtool.c        |    6 +
>>  drivers/net/e1000e/ich8lan.c        |   93 +++-----------------
>>  drivers/net/e1000e/ich8lan.h        |   68 +++++++++++++++
>>  drivers/net/e1000e/netdev.c         |    4 -
>>  drivers/net/e1000e/param.c          |   30 ------
>>  drivers/net/e1000e/quirks.c         |  162 +++++++++++++++++++++++++++++++++++
>>  10 files changed, 256 insertions(+), 114 deletions(-)
>>  create mode 100644 drivers/net/e1000e/ich8lan.h
>>  create mode 100644 drivers/net/e1000e/quirks.c
>>
>>
> 
> This PCI quirk is put in ./drivers/net/e1000e in order to share
> defines and structs found in the driver source, and is only applicable
> to ICHx GbE LOMs supported by that driver anyway.

Seems to be it is not difficult to put it into drivers/pci/quirks.c, 
where it belongs.

	Jeff




