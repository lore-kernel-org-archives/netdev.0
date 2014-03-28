From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Xen-devel] [PATCH net v2 1/3] xen-netback: remove pointless
 clause from if statement
Date: Fri, 28 Mar 2014 11:11:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EB7AC@AcuExch.aculab.com>
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
 <196961493.20140328114238@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Paul Durrant' <Paul.Durrant@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: 'Sander Eikelenboom' <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54266 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750971AbaC1LMR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 07:12:17 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32564-03 for <netdev@vger.kernel.org>;
 Fri, 28 Mar 2014 11:12:15 +0000 (GMT)
In-Reply-To: <196961493.20140328114238@eikelenboom.it>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sander Eikelenboom
> Friday, March 28, 2014, 11:35:58 AM, you wrote:
> 
> > From: Paul Durrant
> >> > A reasonable high estimate for the number of slots required for a specific
> >> > message is 'frag_count + total_size/4096'.
> >> > So if that are that many slots free it is definitely ok to add the message.
> >> >
> >>
> >> Hmm, that may work. By total_size, I assume you mean skb->len, so that calculation is based on an
> >> overhead of 1 non-optimally packed slot per frag. There'd still need to be a +1 for the GSO 'extra'
> >> though.
> 
> > Except I meant '2 * frag_count + size/4096' :-(
> 
> > You have to assume that every fragment starts at n*4096-1 (so need
> > at least two slots). A third slot is only needed for fragments
> > longer that 1+4096+2 - but an extra one is needed for every
> > 4096 bytes after that.
> 
> He did that in his followup patch series .. that works .. for small packets
> But for larger ones it's an extremely wasteful estimate and it quickly get larger than the
> MAX_SKB_FRAGS
> we had before and even to large causing stalls. I tried doing this type of calculation with a CAP of
> the old  MAX_SKB_FRAGS calculation and that works.

I'm confused (easily done).
If you are trying to guess at the number of packets to queue waiting for
the thread that sets things up to run then you want an underestimate.
Since any packets that can't actually be transferred will stay on the queue.
A suitable estimate might be max(frag_count, size/4096).

The '2*frag_count + size/4096' is right for checking if there is enough
space for the current packet - since it gets corrected as soon as the
packet is transferred to the ring slots.

	David
