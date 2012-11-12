From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] ipv4: avoid undefined behavior in do_ip_setsockopt()
Date: Mon, 12 Nov 2012 13:54:11 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B709E@saturn3.aculab.com>
References: <1352668801-14373-1-git-send-email-xi.wang@gmail.com><20121111.170247.780516266044882867.davem@davemloft.net><50A0244F.1070302@gmail.com> <20121111.175056.930119228369321440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54431 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751549Ab2KLOGH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 09:06:07 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08565-10 for <netdev@vger.kernel.org>;
 Mon, 12 Nov 2012 14:05:58 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20121111.175056.930119228369321440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> This code is a fast bit test on purpose.  You're making the
> >> code slower.
> >
> > No, it's the opposite.  All modern compilers optimize switch cases
> > into a fast bit test.

'All modern' is probably an overstatement, 'recent gcc' might be valid.
 
> Indeed, I even checked sparc64 with gcc-4.6 and it looks good.
> 
> Thanks for the clarification, I'll apply this, thanks.

The 'switch' version will have an extra conditional to detect
'out of range' values - even though we know they can't happen.
I'm not sure you can avoid that - even for an enum.

	David
