From: Nathan Sullivan <nathan.sullivan@ni.com>
Subject: Re: [PATCH] MIPS: NI 169445 board support
Date: Thu, 5 Jan 2017 12:44:42 -0600
Message-ID: <20170105184442.GA9424@nathan3500-linux-VM>
References: <1480693329-22265-1-git-send-email-nathan.sullivan@ni.com>
 <20161220163434.GA15962@linux-mips.org>
 <20170104163836.GA18069@nathan3500-linux-VM>
 <5d5a087f-68ec-e633-0232-0248edf11ee0@axis.com>
 <8fd70ecb-36fc-7cc7-7795-cd4dccabf8b9@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Niklas Cassel <niklas.cassel@axis.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        <linux-mips@linux-mips.org>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Lars Persson <larper@axis.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <8fd70ecb-36fc-7cc7-7795-cd4dccabf8b9@synopsys.com>
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

On Thu, Jan 05, 2017 at 06:33:53PM +0000, Joao Pinto wrote:
> Hi,
> 
> Às 6:28 PM de 1/5/2017, Niklas Cassel escreveu:
> > On 01/04/2017 05:38 PM, Nathan Sullivan wrote:
> >> On Tue, Dec 20, 2016 at 05:34:34PM +0100, Ralf Baechle wrote:
> >>> On Fri, Dec 02, 2016 at 09:42:09AM -0600, Nathan Sullivan wrote:
> >>>> Date:   Fri, 2 Dec 2016 09:42:09 -0600
> >>>> From: Nathan Sullivan <nathan.sullivan@ni.com>
> >>>> To: ralf@linux-mips.org, mark.rutland@arm.com, robh+dt@kernel.org
> >>>> CC: linux-mips@linux-mips.org, devicetree@vger.kernel.org,
> >>>>  linux-kernel@vger.kernel.org, Nathan Sullivan <nathan.sullivan@ni.com>
> >>>> Subject: [PATCH] MIPS: NI 169445 board support
> >>>> Content-Type: text/plain
> >>>>
> >>>> Support the National Instruments 169445 board.
> >>> Nathan,
> >>>
> >>> I assume you're going to repost the changes Rob asked for in
> >>> https://urldefense.proofpoint.com/v2/url?u=https-3A__patchwork.linux-2Dmips.org_patch_14641_-2326924&d=DgICaQ&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=5p7f9dIkvVVK4UFHimMpezq5NwIJfUpd08c-Zk4_c6c&s=_JwSwe4VFYtxV1tcYt6Z8r4hJX0xfoGhCixygUxlg5s&e=  and resubmit?
> >>>
> >>> Thanks,
> >>>
> >>>   Ralf
> >> Hmm, I found the issue with the generic MIPS config and dwc_eth_qos.  The NIC
> >> driver attempts to cache align a descriptor ring using the ___cacheline_aligned
> >> attribute on the descriptor struct, in combination with a "skip" feature in
> >> hardware.  However, the skip feature only has a three bit field, and the generic
> >> MIPS config selects MIPS_L1_CACHE_SHIFT_7.  So, the line size is 128, and with a
> >> 64-bit bus, that means the NIC descriptor skip field would need to be set to
> >> 14 to align the 16-byte descriptors...
> >>
> >> I guess it makes sense for a generic MIPS kernel to align everything for 128 byte
> >> cache lines, and for me to fix the dwc_eth_qos driver to handle cases where the
> >> line size is too big for the hardware skip feature, right?
> > 
> > I don't know if you've been following the discussion regarding
> > dwc_eth_qos on netdev, but Joao Pinto from Synopsys is
> > planning on removing the driver (since the stmmac driver
> > now supports the same version of the IP, together with older
> > versions of the IP).
> > 
> > Since device tree bindings are treated as an ABI,
> > Joao has implemented a glue layer for stmmac that parses
> > the dwc_eth_qos binding, but uses stmmac under the hood.
> > 
> > You can use any of the bindings, but since the dwc_eth_qos
> > binding will be marked as deprecated, you might want to
> > consider moving to the stmmac binding.
> 
> A patch set to port dwc_eth_qos to stmmac is at this moment under review:
> 
> http://patchwork.ozlabs.org/patch/711428/
> http://patchwork.ozlabs.org/patch/711438/
> http://patchwork.ozlabs.org/patch/711439/
> 
> Niklas has tested it and it works well, so after the patches are upstreamed the
> dwc_eth_qos will be removed as agreed with Lars.
> 
> Thanks.
>

Thanks for the heads up, I'll wait, adjust my bindings and retest then.

   Nathan

> > 
> >>
> >> Thanks,
> >>
> >>    Nathan
> >>
> >>
> > 
> 
