From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: usb: initialize tmp in dm9601.c to avoid warning
Date: Fri, 18 Jan 2013 10:07:20 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7116@saturn3.aculab.com>
References: <87wqvbjujl.fsf@dell.be.48ers.dk><20130117.175454.200184894667897570.davem@davemloft.net><87sj5zj60q.fsf@dell.be.48ers.dk> <20130118.030341.2246222347501217868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <sque@chromium.org>, <netdev@vger.kernel.org>, <msb@chromium.org>
To: "David Miller" <davem@davemloft.net>, <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42680 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751714Ab3ARKJZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 05:09:25 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12914-02 for <netdev@vger.kernel.org>;
 Fri, 18 Jan 2013 10:09:20 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20130118.030341.2246222347501217868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Sure, I just wondered as the code hasn't changed in 5+ years, and the
> > function that gets called is defined just above, so the compiler should
> > be able to figure it out.
> 
> Nothing guarentees that a piece of memory passed into an external
> function has it's contents initialized completely by that function.
> 
> The compiler can't see what usbnet_read_cmd() does with the memory
> behind the 'data' pointer argument.  So it makes the only assumption
> it can make, which is that 'tmp' might be uninitialized.

Possibly the called function is being inlined, then the analysis
knows that some paths don't assign a value.
When it isn't inlined it assumes the value is always modified.

	David
