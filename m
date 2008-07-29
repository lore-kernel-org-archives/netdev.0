From: Ian Jeffray <ian@jeffray.co.uk>
Subject: Re: sendfile() behavior while troubleshooting netdevice
Date: Tue, 29 Jul 2008 01:27:09 +0100
Message-ID: <488E63DD.4020406@jeffray.co.uk>
References: <20080728190707.329d247b@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.blueyonder.co.uk ([195.188.213.6]:53131 "EHLO
	smtp-out3.blueyonder.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751471AbYG2A1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 20:27:24 -0400
In-Reply-To: <20080728190707.329d247b@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> I'm troubleshooting the problem reported here and I need some help:  
> http://lkml.org/lkml/2008/7/15/325.  

[snip]

> The last round came up short 8 bytes.  Any idea why?  Client and server
> source code attached.
> 
> It doesn't matter which host is the server or client; data is lost
> either way.

Because you send() a strlen() amount of data for the filesize,
but recv() a sizeof(cfsize) amount of data?   I supect 8 bytes
is being sucked up in your first recv().  Try sending a fixed
size block for the file size.

Ian.

