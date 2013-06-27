From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 4/8] qlcnic: Add support for PEX DMA method to read memory section of adapter dump
Date: Thu, 27 Jun 2013 09:56:17 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B72AC@saturn3.aculab.com>
References: <1371832261-18930-1-git-send-email-jitendra.kalsaria@qlogic.com> <1371832261-18930-5-git-send-email-jitendra.kalsaria@qlogic.com> <AE90C24D6B3A694183C094C60CF0A2F6026B72A0@saturn3.aculab.com> <262CB373A6D1F14F9B81E82F74F77D5A4DAE09@avmb2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>,
	"Sony Chacko" <sony.chacko@qlogic.com>,
	"Dept-NX Linux NIC Driver" <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: "Shahed Shaikh" <shahed.shaikh@qlogic.com>,
	"Jitendra Kalsaria" <jitendra.kalsaria@qlogic.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53111 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752093Ab3F0I4y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 04:56:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16265-10 for <netdev@vger.kernel.org>;
 Thu, 27 Jun 2013 09:56:51 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <262CB373A6D1F14F9B81E82F74F77D5A4DAE09@avmb2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > +	if ((tmpl_hdr->version & 0xffffff) >= 0x20001)
> > > +		ahw->fw_dump.use_pex_dma = true;
> > > +	else
> > > +		ahw->fw_dump.use_pex_dma = false;
> >
> > You know what's wrong with the above....
> 
> Yes. Got it.  Masking is not done properly. It should be
> if ((tmpl_hdr->version & 0xfffff) >= 0x20001)

Try:
	ahw->fw_dump.use_pex_dma = (tmpl_hdr->version & 0xfffff) >= 0x20001;

	David
