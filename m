From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch] isdn: make sure strings are null terminated
Date: Thu, 24 Nov 2011 12:30:00 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE0@saturn3.aculab.com>
References: <4ECE36D6.7060503@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Karsten Keil" <isdn@linux-pingi.de>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: <wharms@bfs.de>, "Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56752 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754706Ab1KXMbz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 07:31:55 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20302-01 for <netdev@vger.kernel.org>;
 Thu, 24 Nov 2011 12:31:51 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <4ECE36D6.7060503@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> >>> +			if (strlen(dioctl.cf_ctrl.msn) >=
sizeof(dioctl.cf_ctrl.msn))
> >>> +				return -EINVAL;
...
> So far i see you do not get a string, you get a structure. And 
> it will hard to validate the element is a useful string.
> I think my (sledgehammer) method is ok here because you
> make sure that all later calls (strcmp,strcpy) will succeed.
> If someone supplies a bad string the later calls will catch 
> by failing to identify and return a proper code from there
> (at least i hope so).
> 
> re,
>  wh

Except that the strlen() can run right off the end
of the structure - and might eventually fault.
You need to use something like strnlen().

	David
