From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 8/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Tue, 11 Mar 2014 15:51:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DAA4B@AcuExch.aculab.com>
References: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
	<1394493277-2105-9-git-send-email-vbridgers2013@gmail.com>
	<20140310174031.4145a3ff@nehalam.linuxnetplumber.net>
 <CAOwfj2O8p2MQtFhaLrSzjRAnOYtR2qS3POXaaDd=3qtnwwovZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: 'Vince Bridgers' <vbridgers2013@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAOwfj2O8p2MQtFhaLrSzjRAnOYtR2qS3POXaaDd=3qtnwwovZg@mail.gmail.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers
> On Mon, Mar 10, 2014 at 7:40 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Mon, 10 Mar 2014 18:14:36 -0500
> > Vince Bridgers <vbridgers2013@gmail.com> wrote:
> >
> >> +
> >> +     buf[0] = (u64) ioread32(&mac->frames_transmitted_ok);
> >
> > The cast to u64 is not really necessary, C will do it for you.
> > You do need the cast to do the shift for the 64 bit values.
> 
> Ok, understood. I generally add the cast so it's explicit, but I'll modify.

The problem is that the cast will allow incorrect code to compile.
eg, you might have a pointer, not an integer.

Many years ago I got caught out by a #define like the following:
#define foo(ptr) { int s = splhi(); do_foo((void *)ptr); splx(s); }
My code crashed because I'd called foo(s).
Now that #define is broken in so many ways, but the (void *) cast
stopped the compiler erroring one of them.

	David



