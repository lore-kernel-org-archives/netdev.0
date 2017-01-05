From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: Re: [PATCH] MIPS: NI 169445 board support
Date: Thu, 5 Jan 2017 19:28:24 +0100
Message-ID: <5d5a087f-68ec-e633-0232-0248edf11ee0@axis.com>
References: <1480693329-22265-1-git-send-email-nathan.sullivan@ni.com>
 <20161220163434.GA15962@linux-mips.org>
 <20170104163836.GA18069@nathan3500-linux-VM>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Lars Persson <larper@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: Nathan Sullivan <nathan.sullivan@ni.com>,
        Ralf Baechle <ralf@linux-mips.org>, <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20170104163836.GA18069@nathan3500-linux-VM>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 01/04/2017 05:38 PM, Nathan Sullivan wrote:
> On Tue, Dec 20, 2016 at 05:34:34PM +0100, Ralf Baechle wrote:
>> On Fri, Dec 02, 2016 at 09:42:09AM -0600, Nathan Sullivan wrote:
>>> Date:   Fri, 2 Dec 2016 09:42:09 -0600
>>> From: Nathan Sullivan <nathan.sullivan@ni.com>
>>> To: ralf@linux-mips.org, mark.rutland@arm.com, robh+dt@kernel.org
>>> CC: linux-mips@linux-mips.org, devicetree@vger.kernel.org,
>>>  linux-kernel@vger.kernel.org, Nathan Sullivan <nathan.sullivan@ni.com>
>>> Subject: [PATCH] MIPS: NI 169445 board support
>>> Content-Type: text/plain
>>>
>>> Support the National Instruments 169445 board.
>> Nathan,
>>
>> I assume you're going to repost the changes Rob asked for in
>> https://patchwork.linux-mips.org/patch/14641/#26924 and resubmit?
>>
>> Thanks,
>>
>>   Ralf
> Hmm, I found the issue with the generic MIPS config and dwc_eth_qos.  The NIC
> driver attempts to cache align a descriptor ring using the ___cacheline_aligned
> attribute on the descriptor struct, in combination with a "skip" feature in
> hardware.  However, the skip feature only has a three bit field, and the generic
> MIPS config selects MIPS_L1_CACHE_SHIFT_7.  So, the line size is 128, and with a
> 64-bit bus, that means the NIC descriptor skip field would need to be set to
> 14 to align the 16-byte descriptors...
>
> I guess it makes sense for a generic MIPS kernel to align everything for 128 byte
> cache lines, and for me to fix the dwc_eth_qos driver to handle cases where the
> line size is too big for the hardware skip feature, right?

I don't know if you've been following the discussion regarding
dwc_eth_qos on netdev, but Joao Pinto from Synopsys is
planning on removing the driver (since the stmmac driver
now supports the same version of the IP, together with older
versions of the IP).

Since device tree bindings are treated as an ABI,
Joao has implemented a glue layer for stmmac that parses
the dwc_eth_qos binding, but uses stmmac under the hood.

You can use any of the bindings, but since the dwc_eth_qos
binding will be marked as deprecated, you might want to
consider moving to the stmmac binding.

>
> Thanks,
>
>    Nathan
>
>
