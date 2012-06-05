From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Tue, 5 Jun 2012 21:22:48 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4E05@EAPEX1MAIL1.st.com>
References: <D5ECB3C7A6F99444980976A8C6D896384FA5EC4DFC@EAPEX1MAIL1.st.com>
  <4FC135C6.5030206@grandegger.com> <1677842.Pq7naXsvrI@harkonnen>
  <D5ECB3C7A6F99444980976A8C6D896384FA5EC4B37@EAPEX1MAIL1.st.com>
  <3650428.HarNR9HfNF@harkonnen> <20120605131337.GA15432@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "federico.vaga@gmail.com" <federico.vaga@gmail.com>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	Giancarlo ASNAGHI <giancarlo.asnaghi@st.com>,
	"alan@linux.intel.com" <alan@linux.intel.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "rubini@gnudd.com" <rubini@gnudd.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20120605131337.GA15432@mail.gnudd.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: rubini@gnudd.com [mailto:rubini@gnudd.com]
> Sent: Tuesday, June 05, 2012 6:44 PM
> To: Bhupesh SHARMA
> Cc: federico.vaga@gmail.com; alan@lxorguk.ukuu.org.uk;
> wg@grandegger.com; mkl@pengutronix.de; Giancarlo ASNAGHI;
> alan@linux.intel.com; linux-can@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
> 
> >> My implementation is align to 32, but I'm trying to make a generic
> PCI
> >> wrapper (some other could be aligned to 16)
> 
> > So it means your implementation is also flaky and you are probably
> > wasting HW memory space while integrating the Bosch C_CAN module in
> > your SoC :)
> 
> Then I may say _your_ implementation is flaky because it wastes one
> bit in the address decoder and a lot of logic gates in the data
> bus. It's normal to align registers at 32 bits, as it's simpler and
> faster.  Most SoCs have only 32-bit aligned registers, for a reason.

You missed my original point. I mentioned in my first mail itself, that I studied a
few SoCs integrating the C_CAN module from Bosch before writing the driver.
Not all have aligned their register space to a 32-bit boundary. 
My platform driver still supports them. This _does_ not imply that our
SoC has/may have the same problem :)

Each SoC designer can have his/her own different view on this sort of implementation.
The platform driver was written to support both the implementations (SW is supposed
to support all sort of HW design constraints :) ).

> > I am not a big fan of adding platform specific flakes in any core
> > file, that why we keep the platform file separate from the core
> > ones.
> 
> A number of other drivers have a shift parameter, because it's very
> common for the hardware integrator to feel free to choose the easiest
> wiring for the device.  The choice to keep the platform driver
> separate from the core driver only adds complication in my opinion:
> you need to export 4 symbols and yhen every user must duplicate code
> (like federico is replicating theplatform driver in the pci driver).
> 
> I'd really prefer to have the core driver be a platform driver, and
> the others just add platform data to describe how it is wired. That's
> actually the reason why the platform bus exists.
> 
> > But I will left Marc and Wolfgang to further comment on the same.
> 
> I agree: let them decide.

Sure..

Regards,
Bhupesh
