From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 2/3] if_link: Add VF multicast promiscuous control
Date: Mon, 23 Feb 2015 13:52:33 +0000
Message-ID: <54EB30A1.9080309@solarflare.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38840@BPXM14GP.gisp.nec.co.jp> <54E73BE4.2040505@solarflare.com> <F6FB0E698C9B3143BDF729DF22286646912AD3E7@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F6FB0E698C9B3143BDF729DF22286646912AD3E7@ORSMSX110.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/02/15 21:05, Skidmore, Donald C wrote:
> If a vender specific interface is objectionable maybe a simpler and more generic interface would be for the PF to be able to set a given VF into "trusted" mode... I admit exactly what 'trusted' meant would vary from vender to vender, but it would be a way for the driver to know it could allow configurations such as this.  Just an idea, since we seem to be getting more requests for things such as this.
That's an even worse idea; now you have a generic interface with
completely undefined semantics.
The right way to do this, imho, is to use one of the standard interfaces
for driver-specific gubbins - e.g. sysfs, genetlink or even (whisper it)
ioctls - and put your 'VF promisc mode' setting there.  That way you
have a vendor-specific interface with vendor-specified semantics.
Of those options, I'd recommend sysfs as the best fit.
