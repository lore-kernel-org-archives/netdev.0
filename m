From: Jon Mason <jdmason@kudzu.us>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Mon, 16 Jul 2012 21:48:56 -0700
Message-ID: <CAPoiz9zKgaZLwcFgpQ7fmpjHEiX_3iO2uz5G50L4pL9x7oKi2w@mail.gmail.com>
References: <4FFE6BB9.4060106@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F033B@ORSMSX102.amr.corp.intel.com>
	<4FFE787B.9050201@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F0ACC@ORSMSX102.amr.corp.intel.com>
	<4FFF61BD.1060604@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F11FF@ORSMSX102.amr.corp.intel.com>
	<4FFFA532.1030208@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F2354@ORSMSX102.amr.corp.intel.com>
	<20120715133510.GA5484@khazad-dum.debian.net>
	<1342453645.2523.17.camel@bwh-desktop.uk.solarflarecom.com>
	<20120716160807.GB1765@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	Joe Jin <joe.jin@oracle.com>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:43300 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab2GQEs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 00:48:58 -0400
Received: by lbbgm6 with SMTP id gm6so102621lbb.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 21:48:56 -0700 (PDT)
In-Reply-To: <20120716160807.GB1765@khazad-dum.debian.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 16, 2012 at 9:08 AM, Henrique de Moraes Holschuh
<hmh@hmh.eng.br> wrote:
> On Mon, 16 Jul 2012, Ben Hutchings wrote:
>> On Sun, 2012-07-15 at 10:35 -0300, Henrique de Moraes Holschuh wrote:
>> > On Sun, 15 Jul 2012, Dave, Tushar N wrote:
>> > > Somehow setting max payload to 256 from BIOS does not set this value for all devices. I believe this is a BIOS bug.
>> >
>> > And preferably, Linux should complain about it.  Since we know it is going
>> > to cause problems, and since we know it does happen, we should be raising a
>> > ruckus about it in the kernel log (and probably fixing it to min(path) while
>> > at it)...
>> >
>> > Is this something that should be raised as a feature request with the
>> > PCI/PCIe subsystem?
>>
>> The feature is there, but we ended up with:
>>
>> commit 5f39e6705faade2e89d119958a8c51b9b6e2c53c
>> Author: Jon Mason <mason@myri.com>
>> Date:   Mon Oct 3 09:50:20 2011 -0500
>>
>>     PCI: Disable MPS configuration by default
>>
>> But you are welcome to share use of the fixup_mpss_256() quirk.
>
> Meh.  I'd be happy with a warning if MPSS decreases when walking up to
> the tree root... i.e. a warning if any child has a MPSS larger than the
> parent.

You can add "pci=pcie_bus_safe" to the kernel params and it should
resolve your issue.

> --
>   "One disk to rule them all, One disk to find them. One disk to bring
>   them all and in the darkness grind them. In the Land of Redmond
>   where the shadows lie." -- The Silicon Valley Tarot
>   Henrique Holschuh
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
