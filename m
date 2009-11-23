From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: icmp redirects problem
Date: Mon, 23 Nov 2009 22:58:38 +0100
Message-ID: <4B0B058E.3050906@gmail.com>
References: <20091123043124.GA14795@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alex Samad <alex@samad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:59012 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213AbZKWV7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 16:59:08 -0500
Received: by bwz23 with SMTP id 23so5753781bwz.29
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 13:59:12 -0800 (PST)
In-Reply-To: <20091123043124.GA14795@samad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Samad wrote, On 11/23/2009 05:31 AM:

> Hi

Hi

> 
> 
> I seem to be having problems with icmp redirects
> I have 

...

> 
> net.ipv4.conf.all.accept_redirects = 0                                                                                                                                          
> net.ipv4.conf.all.secure_redirects = 1                                                                                                                                          
> (presume all the interface ones are 1)
> 
> as my default, the documentation seems to suggest that I don't need the
> former for the later to work ie I can have either one.

...

> 
> But for me to get this to work I had to set 
> 
> net.ipv4.conf.all.accept_redirects = 1
> net.ipv4.conf.all.secure_redirects = 1
> 
> to get it to work properly.
> 
> My understanding is secure_redirects means that the kernel should listen
> to icmp redirect if the redirect comes from the default gateway as per
> the route table.
> 
> laptop gets its ip from dchp server that make 192.168.11.1 the default
> gateway and its 192.168.11.1 that sends out the icmp redirect.

Btw, it seems you should fix your routing (by adding sydrt01's eth0
the second ip or advertising 192.168.11.10 more) to avoid those
redirects.

> 
> I had a quick look at the kernel tree for 2.6.31 (which is what I am
> using).

...

> Line 680
>  secure_redirects - BOOLEAN
>  681         Accept ICMP redirect messages only for gateways,
>  682         listed in default gateway list.
>  683         secure_redirects for the interface will be enabled if at
>  least one of
>  684         conf/{all,interface}/secure_redirects is set to TRUE,
>  685         it will be disabled otherwise
>  686         default TRUE

Very helpful links. So, as you wrote "the documentation seems to suggest"
something, and IMHO even if it doesn't, it's needlessly too concise
considering your "lost time", and I'd suggest you sending a patch to fix
this. (It seems it could "touch" shared_media, as well.)

Thanks,
Jarek P.
