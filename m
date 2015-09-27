From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Sun, 27 Sep 2015 16:09:25 +0200
Message-ID: <3461169.v5xKdGLGjP@vostro.rjw.lan>
References: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org> <2524822.pQu4UKMrlb@vostro.rjw.lan> <1443297128.2181.11.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: Viresh Kumar <viresh.kumar@linaro.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
	"open list:AMD IOMMU (AMD-VI)" <iommu@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"open list:NETWORKING DRIVERS (WIRELESS)"
	<linux-wireless@vger.kernel.org>,
	"open list:TARGET SUBSYSTEM" <linux-scsi@vger.kernel.org>,
	"open list:ULTRA-WIDEBAND (UWB) S
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1443297128.2181.11.camel@HansenPartnership.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, September 26, 2015 12:52:08 PM James Bottomley wrote:
> On Fri, 2015-09-25 at 22:58 +0200, Rafael J. Wysocki wrote:
> > On Friday, September 25, 2015 01:25:49 PM Viresh Kumar wrote:
> > > On 25 September 2015 at 13:33, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> > > > You're going to change that into bool in the next patch, right?
> > > 
> > > Yeah.
> > > 
> > > > So what if bool is a byte and the field is not word-aligned
> > > 
> > > Its between two 'unsigned long' variables today, and the struct isn't packed.
> > > So, it will be aligned, isn't it?
> > > 
> > > > and changing
> > > > that byte requires a read-modify-write.  How do we ensure that things remain
> > > > consistent in that case?
> > > 
> > > I didn't understood why a read-modify-write is special here? That's
> > > what will happen
> > > to most of the non-word-sized fields anyway?
> > > 
> > > Probably I didn't understood what you meant..
> > 
> > Say you have three adjacent fields in a structure, x, y, z, each one byte long.
> > Initially, all of them are equal to 0.
> > 
> > CPU A writes 1 to x and CPU B writes 2 to y at the same time.
> > 
> > What's the result?
> 
> I think every CPU's  cache architecure guarantees adjacent store
> integrity, even in the face of SMP, so it's x==1 and y==2.  If you're
> thinking of old alpha SMP system where the lowest store width is 32 bits
> and thus you have to do RMW to update a byte, this was usually fixed by
> padding (assuming the structure is not packed).  However, it was such a
> problem that even the later alpha chips had byte extensions.

OK, thanks!

Rafael

