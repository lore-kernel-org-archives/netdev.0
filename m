From: "Jiang, Dave" <dave.jiang@intel.com>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Wed, 1 Aug 2012 02:18:45 +0000
Message-ID: <98D21DD6-3BDE-402D-8DC1-0AAD79502B8F@intel.com>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
	<1343607994-32415-2-git-send-email-jon.mason@intel.com>
	<CAErSpo4p_hxvCeVGqiTXVq3itXepheQZerpqRHwLvG6A7R2Lcg@mail.gmail.com>
	<20120730181542.GA987@jonmason-lab>
	<CAF8raN6M0_TWyCCzjyXZcFYP=vgFaqQg4hNmNpBxSM+D0C_Bpg@mail.gmail.com>
	<20120731163308.GA13610@jonmason-lab>,<CAF8raN4QFnQ+9k_OGEkYexnK=knQESRSbOgsErNiA8z9MXzZ3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Mason, Jon" <jon.mason@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Jianbin Kang <kjbmail@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAF8raN4QFnQ+9k_OGEkYexnK=knQESRSbOgsErNiA8z9MXzZ3A@mail.gmail.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jul 31, 2012, at 7:10 PM, "Jianbin Kang" <kjbmail@gmail.com> wrote:

>> Actually this is what I'm working on now, using async_tx to replace the
>> memcpy.  I believe the changes shouldn't be that significant.
>> 
>> Is the "hardware that can setup dma" you refer to something that does
>> not use this interface?
>> 
> 
> Yes, they use this interface, but split 'memcpy_toio' to two operation:
>     1. setup dma
>     2. wait/poll for the dma to finish.
> So maybe it need to provide a generic function 'tx' for different hardwares.
> 
It's not worth it to do sync DMA. The performance is terrible. 

> If async_tx is available, it's much better than this 'sync dma/memcpy'.
> One problem with async_tx is, it can't detect memcpy error.
> If the remote ntb goes down when async_memcpy is in operation, async_tx
> will trigger an oops.

Yes that is something that needs to be addressed when we get async DMA support working. 