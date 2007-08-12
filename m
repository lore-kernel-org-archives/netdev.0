From: Michael Buesch <mb@bu3sch.de>
Subject: Re: dm9000: add set_mac_address() v2
Date: Mon, 13 Aug 2007 00:58:59 +0200
Message-ID: <200708130059.00117.mb@bu3sch.de>
References: <20070812192741.GB27490@gandalf.sssup.it> <200708130026.07221.mb@bu3sch.de> <46BF8D7D.5070105@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Michael Trimarchi <trimarchi@gandalf.sssup.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50613
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303AbXHLW7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2007 18:59:43 -0400
In-Reply-To: <46BF8D7D.5070105@gandalf.sssup.it>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 00:45:17 Michael Trimarchi wrote:
> 
> >> +		return -EBUSY;
> >> +
> >> +	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
> >> +
> >> +	for (i = 0; i < 3; i++)
> >> +		write_srom_word(db, i,
> >> +				cpu_to_le16(((u16 *) (addr->sa_data))[i]));
> >>     
> >
> > Nope.
> >
> > write_srom_word(db, i, le16_to_cpu(((__le16 *) (addr->sa_data))[i]));
> >
> >   
> Are you sure?

Yes I am. cpu_to_le16 simply doesn't make any sense at all here,
while le16_to_cpu does make sense and is indeed correct.
Though they both generate the same asm code. Running sparse
also tells you more about this. ;)

-- 
Greetings Michael.
