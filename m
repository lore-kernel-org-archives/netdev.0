From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Wrong use of MAX_JIFFY_OFFSET?
Date: Tue, 27 Mar 2012 09:54:55 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EBA@saturn3.aculab.com>
References: <000901cd0bb8$77fdc460$67f94d20$@com.cn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Liu Yu" <liuyums@bwstor.com.cn>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:35075 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757733Ab2C0I4L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 04:56:11 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22323-03 for <netdev@vger.kernel.org>;
 Tue, 27 Mar 2012 09:56:07 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <000901cd0bb8$77fdc460$67f94d20$@com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Liu Yu
> Sent: 27 March 2012 02:25
> To: netdev@vger.kernel.org
> Subject: Wrong use of MAX_JIFFY_OFFSET?
> 
> Hi guys,
> 
> I saw a couple of places in current kernel have this kind of code:
> 
> > static inline unsigned int elapsed_jiffies_msecs(unsigned 
> long start)
> > {
> >         unsigned long end = jiffies;
> >
> >         if (end >= start)
> >                return jiffies_to_msecs(end - start);
> >
> >         return jiffies_to_msecs(end + (MAX_JIFFY_OFFSET - 
> start) + 1);
> > }
> 
> As you know, jiffies has a type of unsigned long, so if we 
> know which is the end and
> which is the start, then (end - start) can simply figure out how much
> jiffies flies, without worry about the overflow.
> 
> Look at the code above, assume that there is just an overflow 
> happening on
> jiffies: end=0 and start=~0UL.
> Since end < start, then the return value of the function is
> jiffies_to_msecs(MAX_JIFFY_OFFSET+2).
> But shouldn't the correct value be jiffies_to_msecs(1)?
> 
> could someone tell me that am I missing anything?

That code has confused me...
MAX_JIFFIES_OFFSET appears to have something to do with
timespec_to_jiffies() rather than being anything to so with
the way 'jiffies' itself wraps.

Since arithmetic wrap is well defined for unsigned values
the correct code should just be:
	return jiffies_to_ms(jiffies - start);
The code above is completly fubar when jiffies wraps.

	David
