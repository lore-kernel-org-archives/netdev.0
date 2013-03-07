From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] iputils: fix memory leaks
Date: Thu, 7 Mar 2013 10:06:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7181@saturn3.aculab.com>
References: <loom.20130307T103516-549@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "jb" <jb.1234abcd@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34293 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752531Ab3CGKLC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 05:11:02 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15781-06 for <netdev@vger.kernel.org>;
 Thu,  7 Mar 2013 10:10:58 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <loom.20130307T103516-549@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>     Fix memory leaks
...
> +#ifdef USE_IDN
> +                               free(idn);
> +                               idn = NULL;
> +#endif
>                                 exit(2);

There is no point calling free() before exit(), nor any need
to free items that aren't allocated inside loops.

	David
