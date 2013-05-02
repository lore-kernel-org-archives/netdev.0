From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 1/3] be2net: Fix firmware download for Lancer
Date: Thu, 2 May 2013 15:37:41 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7221@saturn3.aculab.com>
References: <18c7d598-93d2-4770-b314-586dec18b9be@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, "Kalesh AP" <kalesh.purayil@emulex.com>
To: "Somnath Kotur" <somnath.kotur@emulex.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43581 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1760060Ab3EBOjW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 10:39:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02413-02 for <netdev@vger.kernel.org>;
 Thu,  2 May 2013 15:39:17 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <18c7d598-93d2-4770-b314-586dec18b9be@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Increasing the timeout value of write_object command to 60 seconds as
> 30 second timeout was found to be not enough for the command to complete.
...
>  	if (!wait_for_completion_timeout(&adapter->flash_compl,
> -					 msecs_to_jiffies(30000)))
> +					 msecs_to_jiffies(60000)))

If an operation is likely to take over 30 seconds I'd expect
the 'guard timer' to be much longer than 60 seconds.

OTOH if an ioctl() call (or similar) into a driver is going
to sleep for that long users are going to start getting worried.

I'm not sure what the answer is, but some kind of confirmation
that the operation is proceeding would be more useful.

I presume that the time is taken doing flash sector erases
and writes? 30 seconds is still a lot of flash erases.

Perhaps the flash code could decrement a counter and wake the
user process every time it finishes a sector. The application
could then report progress - and the timeout would only need
to be long enough for a single sector erase/write.

	David
