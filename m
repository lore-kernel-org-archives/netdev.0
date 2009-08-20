From: Aviv Greenberg <avivgnet@gmail.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 20 Aug 2009 16:17:39 +0300
Message-ID: <3000d2e90908200617w3716c57ck490afa716f920e92@mail.gmail.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	 <20090808183251.GA23300@localhost.localdomain>
	 <20090811033210.6b422ed1.billfink@mindspring.com>
	 <87ws5af0km.fsf@basil.nowhere.org>
	 <20090812003049.185cd52a.billfink@mindspring.com>
	 <4A856781.2080301@myri.com>
	 <20090814123832.a7a27a9d.billfink@mindspring.com>
	 <4A859716.7040904@myri.com>
	 <3000d2e90908141413h3e3eae1dm796f4bf788319561@mail.gmail.com>
	 <20090820032601.03a628cf.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Gallatin <gallatin@myri.com>, netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:57501 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbZHTNRj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 09:17:39 -0400
Received: by bwz19 with SMTP id 19so5336256bwz.37
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 06:17:39 -0700 (PDT)
In-Reply-To: <20090820032601.03a628cf.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 10:26, Bill Fink<billfink@mindspring.com> wrote=
:
> IIRC, under DevCap they indicated MaxPayload 4096 bytes, and under
> DevCtl they indicated MaxPayload 128 bytes and MaxReadReq 4096 bytes,
> and was the same on both the Asus and SuperMicro systems. =A0I will
> doublecheck tomorrow at work. =A0I am not clear on the meanings of
> the different parameters. =A0And is DevCtl for PCI control messages
> and DevCap for actual data transfers or something else?

IIRC DevCap is what the device is capable of, and DevCtl is a control
register that is used to limit the device's PCIe MTU if needed (e.g
chipset limit). MaxPayload is the one used for RX DMA writes, and 128
bytes might be too low. I suggest you double check that.

You have to first figure out if your performance is limited by PCIe
bandwidth, or due to the NUMA stuff.

--=20

Stephen Leacock  - "I detest life-insurance agents: they always argue
that I shall some day die, which is not so." -
http://www.brainyquote.com/quotes/authors/s/stephen_leacock.html
