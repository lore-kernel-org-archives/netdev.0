From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 09:07:52 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Chris Peterson" <cpeterso@cpeterso.com>, <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762138AbYEOQIN@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080515142154.0595e475@core>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> Chris Peterson <cpeterso@cpeterso.com> wrote:
>> I know Jeff Garzik says he's not interested in an anti-entropy
>> pogrom for existing net drivers, but here is the patch if anyone
>> else is interested..? :)  
>> 
>> Only 12 net drivers are affected, the last of the
>> theoretically-exploitable network entropy. 
> 
> Looks fine to me. If Jeff doesn't want to touch them then send them
> direct to Andrew/Linus.
> 
> A more interesting alternative might be to mark things like network
> drivers with a new flag say IRQF_SAMPLE_DUBIOUS so that users can be
> given a switch to enable/disable their use depending upon the
> environment. 

we've been hearing rumblings of big customers wanting (maybe requiring)
wired network drivers from Intel to  advertise this flag.  Jeff have you
heard of such?

I think the argument is that a headless system (no keyboard/mouse, no
soundcard, probably no video) with a libata based driver and a network
driver without IRQF_SAMPLE_RANDOM has *no* sources of entropy.  In this
case the argument is very strong for at least *some* source of entropy
from interrupts so that randomness can get some external input.  Just
try rebuilding a kernel RPM over an ssh session and you'll see what I
mean.

In short, I agree with Alan's IRQF_SAMPLE_DUBIOUS, and know of Linux
customers who also want the same.
