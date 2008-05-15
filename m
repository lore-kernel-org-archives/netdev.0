From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 13:39:54 -0700
Message-ID: <482C9F9A.5070302@intel.com>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	 <20080515142154.0595e475@core>	 <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>	 <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com>	 <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com>	 <482C8D4D.3040702@garzik.org> <a24804730805151301s3c6644d0hc2c78b8008fe035d@mail.gmail.com> <482C9A0E.3020305@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Chris Peterson <cpeterso@cpeterso.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764801AbYEOUm7@vger.kernel.org>
In-Reply-To: <482C9A0E.3020305@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Chris Peterson wrote:
>> Please correct me if I'm wrong, but this thread's conclusions seem to be:
>>
>> * network interrupts are an inappropriate source of entropy (see my
>> patch)
>> * headless servers need entropy, but should seek a better solution,
>> such as EGD, hardware RNG, or other kernel entropy sources (but that
>> is a separate task)
>> * TPM RNG is a separate task and, if implemented, should be in
>> drivers/char/hw_random/
> 
> That's my own opinion, yes.  But not necessarily a consensus opinion :)

I agree it's by far the _best_ solution.

I think that some embedded devices that do not have any RNG hardware should be
able to turn off NAPI/irq mitigation and possibly fall back on IRQF_SA_RANDOM.
It's not as good as the above solution at all, but may be sufficient for headless
embedded devices that are dying for some entropy.

of course, with most of the network drivers being NAPI enabled by default this
pretty much is not realistic (as Jeff G. pointed out). Unless someone writes an
(e.g.) ethtool parameter to turn NAPI on/off :)

Auke

> 
>     Jeff
> 
> 
