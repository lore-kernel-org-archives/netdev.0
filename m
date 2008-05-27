From: <glenn_engel@agilent.com>
Subject: RE: natsemi.c ioctl fix or mii register access
Date: Tue, 27 May 2008 10:29:09 -0600
Message-ID: <010200463BAAFF45926C5BFD8E21F515FD50C7@cos-us-mb01.cos.agilent.com>
References: <010200463BAAFF45926C5BFD8E21F515F523F0@cos-us-mb01.cos.agilent.com> <4835B5C0.2000701@pobox.com> <010200463BAAFF45926C5BFD8E21F515FD47AC@cos-us-mb01.cos.agilent.com> <20080524100429.GA11715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aglsgpbs02.sgp.agilent.com ([192.25.82.31]:59591 "EHLO
	aglsgpbs02.sgp.agilent.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757675AbYE0QpI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 12:45:08 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080524100429.GA11715@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]
> > I suppose this copy could be done in dev.c for these ioctls but it
> would
> > also need to tweak the ifru_data field to point to local storage
> > before/after the ioctl calls.  Perhaps this was the original intent
> and
> > was not noticed since ethtool doesn't use these ioctls. I just
> assumed
> > the natsemi driver was the odd duck but perhaps none of them work
> with
> > these ioctls at this point.
> 
> The type-casting is a bit confusing at times but these ioctls work
> rather
> well in real life, with mii-tool for instance.
> 

OK, I see what you mean.  Even though the ifru_data field is a __user* pointer and nominally 4 bytes long, the mii-tool program is treating it as an 8 byte mii_ioctl_data info structure and ignoring the fact it's a pointer and relying on the fact that other fields in the union are 8 or more bytes long.

Now that I understand the usage I'm wondering if there was a way for me to intuit that the __user* pointer was not really intended to be a user space pointer other than finding the mii-tool source?

Thanks for clearing this up.

--
Glenn

