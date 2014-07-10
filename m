From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 1/4] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Thu, 10 Jul 2014 15:26:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D172700F9@AcuExch.aculab.com>
References: <1404758751-2346-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404758751-2346-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140707221823.GC16677@electric-eye.fr.zoreil.com>
 <20140710151904.GA5283@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: 'Ezequiel Garcia' <ezequiel.garcia@free-electrons.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51989 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751591AbaGJP2c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 11:28:32 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31816-07 for <netdev@vger.kernel.org>;
 Thu, 10 Jul 2014 16:28:22 +0100 (BST)
In-Reply-To: <20140710151904.GA5283@arch.cereza>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia
...
> > > +/* Compare tcam data bytes with a pattern */
> > > +static bool mvpp2_prs_tcam_data_cmp(struct mvpp2_prs_entry *pe,
> > > +				    unsigned int offs, unsigned int size,
> > > +					   unsigned char *bytes)
> > > +{
> > > +	unsigned char byte, mask;
> > > +	int i;

Hmm. should be 'unsigned int' for the comparison against 'size'.

> > > +
> > > +	for (i = 0; i < size; i++) {
> > > +		mvpp2_prs_tcam_data_byte_get(pe, offs + i, &byte, &mask);
> > > +
> > > +		if (byte != bytes[i])
> > > +			return false;
> >
> > Please reduce the scope of "byte" and "mask".
> >
> 
> Agreed. This applies on several other places, I'll fix them all.
> 
> > > +	}
> > > +	return true;

Not sure about other people, but I prefer variables to be defined
at the top of a function so that I can find them.
Minimising the scope tends to make code harder to read.

If this was a big function, then reducing the scope of 'temporary'
variables need for a few lines (like the above loop) can make sense
because it reduces the clutter at the top of the function.

	David
