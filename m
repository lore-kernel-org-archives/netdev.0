From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 3/3] Altera TSE: Add Altera Triple Speed Ethernet
 (TSE) Driver
Date: Tue, 4 Mar 2014 10:06:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CFE20@AcuExch.aculab.com>
References: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
	<1393792922-2381-4-git-send-email-vbridgers2013@gmail.com>
	<5313D3DE.3030907@gmail.com>
 <CAOwfj2OjxyCNwgxWLjv5asDQYKD2Mcd3N_3Wn+jankK-pa35Fw@mail.gmail.com>
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
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39747 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756842AbaCDKGk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:06:40 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09219-09 for <netdev@vger.kernel.org>;
 Tue,  4 Mar 2014 10:06:37 +0000 (GMT)
In-Reply-To: <CAOwfj2OjxyCNwgxWLjv5asDQYKD2Mcd3N_3Wn+jankK-pa35Fw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Vince Bridgers
> Hello Florian, thank you for taking the time to comments. My responses inline.
> 
> On Sun, Mar 2, 2014 at 6:59 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> > Hello Vince,
> >
> > It might help reviewing the patches by breaking the patches into:
> >
> > - the SGDMA bits
> > - the MSGDMA bits
> > - the Ethernet MAC driver per-se
> 
> I'll break down the next submission.
> 
> >
> > BTW, it does look like the SGDMA code could/should be a dmaengine driver?
> 
> I did consider this, but after studying the dmaengine api I found the
> API definitions and semantics were not a match to the way the SGDMA
> and MSGDMA behave collectively. Moreover, I could not find an example
> of an Ethernet driver that made use of the dmaengine API - only the
> Micrel driver seems to use it. When studying what components actually
> used the dmaengine API I concluded the dmaengine API was defined for
> use cases different than Ethernet.

It is probably reasonable to expect that the SGDMA is instantiated for the
sole use of the ethernet block - it probably wants two of them, and then
treat it as part of the ethernet hardware.
I've not looked at the TSE or SGDMA, but I suspect you could require that
they be placed at adjacent Avalon addresses. So that they are effectively
a single device. Qsys might even let you define such a beast.

	David
