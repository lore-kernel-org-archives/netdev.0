From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/5] net: sctp: fix incorrect type in gfp
 initializer
Date: Thu, 19 Jun 2014 08:13:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725EF63@AcuExch.aculab.com>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
 <1402497297-27100-6-git-send-email-dborkman@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725AF78@AcuExch.aculab.com>
 <5398712C.3000801@redhat.com>
 <CAADnVQLyNCUU0+onEHbygVE-M3WK59uB=NoKWi1V4Rh+6AZkVA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725B905@AcuExch.aculab.com>
 <20140618183058.GC11042@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Tejun Heo' <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57815 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757590AbaFSIPH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 04:15:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19139-02 for <netdev@vger.kernel.org>;
 Thu, 19 Jun 2014 09:14:57 +0100 (BST)
In-Reply-To: <20140618183058.GC11042@htj.dyndns.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tejun Heo
> On Thu, Jun 12, 2014 at 08:46:44AM +0000, David Laight wrote:
> > I was slightly worried it might generate the boolean value - something
> > that you really don't want it to do.
> 
> I don't think gcc is that stupid at this point.
> 
> > I only looked at the output for the old version.
> > The compiler seemed to have converted:
> > 	if (preload)
> > 		x();
> > 	y;
> > 	if (preload)
> > 		z();
> > into:
> > 	if (preload) {
> > 		x(); y; z();
> > 	} else {
> > 		y;
> > 	}
> > and then found out that z() was empty, leaving two copies of y().
> 
> So, nothing wrong, right?

Apart from the fact that it is badly optimised.

If z() were an empty #define rather than an empty inline function
then you'd end up with the:
	if (preload)
		z();
being completely optimised away.

	David
