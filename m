From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
 clause from if statement
Date: Fri, 28 Mar 2014 10:44:12 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD029E21D@AMSPEX01CL01.citrite.net>
References: <1395924973-42904-1-git-send-email-paul.durrant@citrix.com>
 <1395924973-42904-2-git-send-email-paul.durrant@citrix.com>
 <289461862.20140327144546@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029C992@AMSPEX01CL01.citrite.net>
 <68689563.20140327150256@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029CAA6@AMSPEX01CL01.citrite.net>
 <874580615.20140327174607@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029D28D@AMSPEX01CL01.citrite.net>
 <636041055.20140327181524@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029D498@AMSPEX01CL01.citrite.net>
 <1279623918.20140327193454@eikelenboom.it>
 <602920213.20140327202235@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029DDEA@AMSPEX01CL01.citrite.net>
 <1144281350.20140328103919@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029DFE7@AMSPEX01CL01.citrite.net>
 <063D6719AE5E284EB5DD2968C1650D6D0F6EB615@AcuExch.aculab.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029E138@AMSPEX01CL01.citrite.net>
 <063D6719AE5E284EB5DD2968C1650D6D0F6EB72D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:12729 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaC1KoN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 06:44:13 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EB72D@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: 28 March 2014 10:36
> To: Paul Durrant; Sander Eikelenboom
> Cc: netdev@vger.kernel.org; Wei Liu; Ian Campbell; xen-devel@lists.xen.org
> Subject: RE: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
> clause from if statement
> 
> From: Paul Durrant
> > > A reasonable high estimate for the number of slots required for a specific
> > > message is 'frag_count + total_size/4096'.
> > > So if that are that many slots free it is definitely ok to add the message.
> > >
> >
> > Hmm, that may work. By total_size, I assume you mean skb->len, so that
> calculation is based on an
> > overhead of 1 non-optimally packed slot per frag. There'd still need to be a
> +1 for the GSO 'extra'
> > though.
> 
> Except I meant '2 * frag_count + size/4096' :-(
> 

And that's the pessimal estimation that's failing for Sander :-(

  Paul

> You have to assume that every fragment starts at n*4096-1 (so need
> at least two slots). A third slot is only needed for fragments
> longer that 1+4096+2 - but an extra one is needed for every
> 4096 bytes after that.
> 
> 	David
> 
> 
