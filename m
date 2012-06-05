From: Alessandro Rubini <rubini@gnudd.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 5 Jun 2012 15:13:37 +0200
Message-ID: <20120605131337.GA15432@mail.gnudd.com>
References: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
  <4FC135C6.5030206@grandegger.com> <1677842.Pq7naXsvrI@harkonnen>
  <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
  <3650428.HarNR9HfNF@harkonnen>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: federico.vaga@gmail.com, alan@lxorguk.ukuu.org.uk,
	wg@grandegger.com, mkl@pengutronix.de, giancarlo.asnaghi@st.com,
	alan@linux.intel.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhupesh.sharma@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> My implementation is align to 32, but I'm trying to make a generic PCI
>> wrapper (some other could be aligned to 16)
 
> So it means your implementation is also flaky and you are probably
> wasting HW memory space while integrating the Bosch C_CAN module in
> your SoC :)

Then I may say _your_ implementation is flaky because it wastes one
bit in the address decoder and a lot of logic gates in the data
bus. It's normal to align registers at 32 bits, as it's simpler and
faster.  Most SoCs have only 32-bit aligned registers, for a reason.

> I am not a big fan of adding platform specific flakes in any core
> file, that why we keep the platform file separate from the core
> ones.

A number of other drivers have a shift parameter, because it's very
common for the hardware integrator to feel free to choose the easiest
wiring for the device.  The choice to keep the platform driver
separate from the core driver only adds complication in my opinion:
you need to export 4 symbols and yhen every user must duplicate code
(like federico is replicating theplatform driver in the pci driver).

I'd really prefer to have the core driver be a platform driver, and
the others just add platform data to describe how it is wired. That's
actually the reason why the platform bus exists.

> But I will left Marc and Wolfgang to further comment on the same.

I agree: let them decide.

/alessandro
