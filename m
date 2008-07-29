From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: sendfile() behavior while troubleshooting netdevice
Date: Tue, 29 Jul 2008 08:16:52 -0500
Message-ID: <488F1844.1070005@bellsouth.net>
References: <20080729093250.GA13365@ff.dom.local>
Reply-To: jacliburn@bellsouth.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian@jeffray.co.uk
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:64321 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461AbYG2NQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 09:16:56 -0400
Received: by an-out-0708.google.com with SMTP id d40so988909and.103
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 06:16:55 -0700 (PDT)
In-Reply-To: <20080729093250.GA13365@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

Jarek Poplawski wrote:
> sfclient.c:
> ...
> 		prev = count;
> 		count += ret;
> 		if (prev == count) {
> 			fprintf(stderr, "error: expected %d, received %d\n",
> 				fsize, count);
> --->			exit(1);
> 		}
> 
> Maybe you could try without this exit if anything comes later?

That's the way I initially had it, but I'd get infinite loops when the 
bytes were lost; no additional bytes ever showed up.  The 'if (prev == 
count)' check was added later, just to kick the thing out of that 
infinite loop.

However, your question made me realize that ret can be -1, and I don't 
want to change 'count' in that case.  Changed to

if (ret > 0)
	count += ret;

Thanks,
Jay
