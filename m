From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 11:04:21 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E9E@saturn3.aculab.com>
References: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Maciej Zenczykowski" <zenczykowski@gmail.com>,
	"Maciej Zenczykowski" <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36846 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752481Ab2CMLFU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 07:05:20 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23833-09 for <netdev@vger.kernel.org>;
 Tue, 13 Mar 2012 11:05:18 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> +	/* For i in 0..7 returns {-1, 0, 1, 0, 2, 0, 1, 0}[i] */
> +	return ((26468 >> (i+i)) & 3) - 1;

That expression doesn't seem quite right to me ...
	return (int)(0x12131210 >> (i * 4)) & 3) - 1;
probably does what is wanted.

	David
