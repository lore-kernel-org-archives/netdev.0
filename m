From: "Joachim Deguara" <joachim.deguara@amd.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Thu, 2 Aug 2007 10:05:44 +0200
Message-ID: <200708021005.45773.joachim.deguara@amd.com>
References: <20070731174522.b141178a.akpm@linux-foundation.org>
 <1185990466.5552.34.camel@dell> <1186002023.18322.7.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"lkml List" <linux-kernel@vger.kernel.org>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1186002023.18322.7.camel@dell>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 August 2007 23:00:23 Michael Chan wrote:
> On Wed, 2007-08-01 at 10:47 -0700, Michael Chan wrote:
> > You have 2 Broadcom devices in your system.  07:00.0 is a wireless
> > device, I think.  8:4.0 is the tg3 device.
> >
> > It's clear that the tg3 device is still in D3 state after resume and
> > that explains why all register accesses fail.  tg3_resume() should put
> > the device back in D0 state in a very straight forward way and I don't
> > see how that can fail.  It worked for me when I tested it last night.
> > Can you add some printk() to tg3_resume() to see what's happening?  Let
> > me know if you want me to send you some debug patches to do that.
>
> I misread the PCI registers below.  The power state was ok.
>
> The problem is that memory enable and bus master were not set in PCI
> register 4 after resume.  This also explains the register access
> failures.
>
> In tg3_resume(), we call pci_restore_state() which should re-enable
> those 2 bits in PCI register 4.  Can you add some printk() to see why
> those bits are not restored after pci_restore_state()?

Reading pci_restore_state() it looks already instrumented.  Sorry about the 
wrong pci device, looking at my BCM5788 it is pci device 08:04.0 and looking 
at the log from my first post there is nothing restored in the first 64 
bytes!  Otherwise it would have said "PM: Writing back..."

Is this what you are looking for or should I do other printk instrumentation?

-Joachim

 


