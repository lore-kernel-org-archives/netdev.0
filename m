From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Thu, 24 Sep 2015 15:01:57 +0100
Message-ID: <20150924140157.GB30475@red-moon>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <1443033714.74600.18.camel@infradead.org>
 <560310EA.2070805@intel.com>
 <1443042212.74600.30.camel@infradead.org>
 <56033C10.2040708@linaro.org>
 <1443082579.74600.48.camel@infradead.org>
 <20150924103152.GG13823@e104818-lin.cambridge.arm.com>
 <1443095558.74600.84.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
 Catalin Marinas <Catalin.Marinas@arm.com>,
 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
 Jeremy Linton <Jeremy.Linton@arm.com>,
 "hanjun.guo@linaro.org" <hanjun.guo@linaro.org>,
 "suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "grant.likely@linaro.org" <grant.likely@linaro.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1443095558.74600.84.camel@infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 12:52:38PM +0100, David Woodhouse wrote:

[...]

> And think about it... we *really* don't want a given peripheral device
> to have *different* bindings depending on whether it's discovered with
> a specific ACPI HID, vs. when it's discovered via DT or the PRP0001
> HID. That way lies complete insanity.

There are "devices" that we do _not_ want to discover at all when
booting with ACPI (eg drivers/clk, drivers/regulator) because the way
they interact with ACPI standard power management AML methods may
definitely clash.

PRP0001 allows to pull everything in (depending on what the Coccinelle
script will look like, because AFAIK that's the only thing that stops
people from enabling eg drivers/clk drivers in ACPI systems with PRP0001,
namely the OF to FW node API conversion).

> In some ways, your proposal would be actively *counterproductive*. You
> say you want to train people *not* to keep patching the kernel. But
> where they *could* have just used PRP0001 and used a pre-existing
> kernel, you then tell them "oh, but now you need to patch the kernel
> because we want you to make up a new HID and not be compatible with
> what already exists."

We do not want people to reuse DT drivers that are handled in ACPI with
existing methods (again, power management is a prime example).

I do not think we want to enable DT PCI host controllers drivers either
since the ACPI model for PCI works differently already.

Should I mention CPUfreq and CPUidle DT drivers ?

The list of concerns goes on, it does not stop here.

> If you go down this road, I predict we'll start seeing *separate*
> drivers for identical components, because the bindings for DT vs. ACPI
> properties are different. We really don't want that.
> 
> > The pro ARM ACPI camp has been very vocal against DT in the server
> > space. I'd like to seem them as vocal about PRP0001, unless they find it
> > acceptable (and should apologise for bashing DT ;)).
> 
> Fundamentally, that DT vs. ACPI distinction has gone away with the
> introduction of _DSD. We *need* the flexibility that we gain from being
> able to provide device properties rather than inventing a new HID for
> every permutation, and with that flexibility comes a certain amount of
> responsibility to do things sensibly.

How do you enforce that apart from limiting the number of drivers you
convert to the FW node API ? What drivers are we going to convert and
on what basis ?

I think that's a debate worth having before making a tree-wide conversion
of OF API calls to the generic FW node API.

Thanks,
Lorenzo
