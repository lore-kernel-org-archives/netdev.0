From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [Xen-devel] printk from softirq on xen: hard lockup
Date: Thu, 6 Aug 2015 17:58:29 +0200
Message-ID: <CAHmME9r1Ugk65OWgATh-aqW9s9QDpC8zckgP180vTAFj32wP9w@mail.gmail.com>
References: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
	<55C0F291.7060806@citrix.com>
	<CAHmME9r6yYyiRXD7hyyvZnk9CvNAxgG5MSb=F=smSV6+j_U_FQ@mail.gmail.com>
	<55C330C7.6050204@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Paul McKenney <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org
To: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55C330C7.6050204@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 6, 2015 at 12:02 PM, David Vrabel <david.vrabel@citrix.com> wrote:
> Linux PV guests must use the "Xen PV" APIC driver.  You need to
> investigate why your PV guest is not using this (although I'm surprised
> it works at all with the wrong one).

Actually it appears this PV Guest is using the "flat" APIC driver
instead of the Xen APIC driver.

But upon further investigation into why:

arch/x86/xen/Makefile:
    obj-$(CONFIG_XEN_DOM0)          += apic.o vga.o

It would appear that only dom0 gets to use the Xen APIC driver.

What gives?

Jason
