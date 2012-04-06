From: Chris Boot <bootc@bootc.net>
Subject: Re: [E1000-devel] e1000e interface hang on 82574L
Date: Fri, 6 Apr 2012 11:17:23 +0100
Message-ID: <1590F833-7D40-42FE-8FA2-6DCCADF9C6B0@bootc.net>
References: <4EFA4024.5000909@bootc.net> <FCF3184D-CE4F-471C-B66C-0F671795FD3C@bootc.net> <9BBC4E0CF881AA4299206E2E1412B626017762@ORSMSX102.amr.corp.intel.com> <4F048861.8070501@bootc.net> <4F12B42C.9030803@bootc.net> <9BBC4E0CF881AA4299206E2E1412B62621F0B1@ORSMSX102.amr.corp.intel.com> <4F144A76.3050703@bootc.net> <4F64B4E2.20208@bootc.net> <4F64CFCB.7060702@bootc.net> <9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com> <87r4wova0b.fsf@spindle.srvr.nix> <9BBC4E0CF881AA4299206E2E1412B6260E512FB9@ORSMSX102.amr.corp.intel.com> <87ehsov6ot.fsf@spindle.srvr.nix>
Mime-Version: 1.0 (Apple Message framework v1276)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <87ehsov6ot.fsf@spindle.srvr.nix>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 Mar 2012, at 17:31, Nix wrote:

> On 19 Mar 2012, Carolyn Wyborny said:
> 
>>> you'll see that I tested that, and it doesn't work :( even if it did
>>> work, it shouldn't be needed: the driver attempts to turn off PCIe ASPM
>>> on affected NICs, and fails, apparently because *something* turns it
>>> back on again.
>>> 
>> The driver attempts to disable L0s state, not the entire feature. It
> 
> It tries to disable L1 state as well (or it did when I tested this last,
> although I suspect you're right and it may leave L1 turned on these
> days: judging by the contents of e1000_82574_info, anyway.)
> 
>> is also required that the device upstream on the bus from the 82574L
>> have this disabled. Yes, I agree there appears to be something in the
>> os that either ren-enables or fails to disable the feature on the
>> upstream device, as desired. Platforms/systems also appear to vary in
>> this regard, so the solutions may vary a bit as well.
>> 
>> Its worth trying your solution as well if what I suggested doesn't
>> work, but there is not one solution that fits all, unfortunately.
> 
> I don't *have* a solution. :( 'setpci by hand some unknown amount of
> time after booting once the interface has stabilized' hardly counts as a
> solution of any sort. It's, at best, a workaround that lets me use my
> systems without hourly lockups until a real solution is found.
> 
> (To clarify: manual setpci to force off the ASPM bits is the only thing
> that works for me. The driver's automatic disabling of L0s and L1
> doesn't work: nor does booting with pcie_aspm=off. In both cases, I end
> up with both L0s and L1 turned on, and a lockup some time later, unless
> I setpci the bits off by hand.)


Well, with that setpci incantation run against the NIC and its upstream device to disable ASPM L1s (setpci -s <dev> CAP_EXP+10.b=40), everything has been working very well indeed. Is there something the e1000e driver could do to disable L1s as well as L0s if we know there's a problem with them for these devices?

Adding Bjorn Helgaas and linux-pci to CCs to try to get the ball rolling some more, as this is crippling without the fixes.

Cheers,
Chris

-- 
Chris Boot
bootc@bootc.net
