From: jamal <hadi@cyberus.ca>
Subject: Re: [Bugme-new] [Bug 15379] New: u32 classifier port range
 calculation error
Date: Thu, 25 Feb 2010 16:47:05 -0500
Message-ID: <1267134425.24915.16.camel@bigi>
References: <bug-15379-10286@http.bugzilla.kernel.org/>
	 <20100224145220.da5ec0b0.akpm@linux-foundation.org>
	 <1267068257.3973.865.camel@bigi>
	 <4a5881461002250325o45965b2fu2855b712b73e00b9@mail.gmail.com>
	 <1267104293.3973.947.camel@bigi>
	 <4a5881461002251111r654b6f90l42a4d596125cb796@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Reinaldo de Carvalho <reinaldoc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f204.google.com ([209.85.216.204]:47435 "EHLO
	mail-px0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933401Ab0BYVrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 16:47:32 -0500
Received: by pxi42 with SMTP id 42so270675pxi.19
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 13:47:32 -0800 (PST)
In-Reply-To: <4a5881461002251111r654b6f90l42a4d596125cb796@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-25 at 16:11 -0300, Reinaldo de Carvalho wrote:

> Testing with mask 0xFFE0... (1 port match)
> 
> # Stats...
> # tc -s filter show dev eth0
> filter parent 1: protocol ip pref 1 u32
> filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht
> 800 bkt 0 flowid 1:1200  (rule hit 13 success 0)
>   match 00001ae0/0000ffe0 at 20 (success 0 )
> 
> # Sending packets...
> # nmap example.ufpa.br -p 1-65535
> 
> # Stats...
> # tc -s filter show dev eth0
> filter parent 1: protocol ip pref 1 u32
> filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht
> 800 bkt 0 flowid 1:1200  (rule hit 65459 success 1)
>   match 00001ae0/0000ffe0 at 20 (success 1 )


Ok, you forced me to setup a system and install nmap.

-------
bigismall:~# tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32 
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1 
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht
800 bkt 0 flowid 1:1200  (rule hit 15 success 0)
  match 00001ae0/0000ffe0 at 20 (success 0 ) 
bigismall:~# nmap bigi -p 1-65535

Starting Nmap 5.00 ( http://nmap.org ) at 2010-02-25 16:40 UTC
Interesting ports on bigi (10.0.0.26):
Not shown: 65532 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
MAC Address: 00:16:2E:12:4D:2E (Unknown)

Nmap done: 1 IP address (1 host up) scanned in 65.55 seconds
bigismall:~# tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32 
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1 
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht
800 bkt 0 flowid 1:1200  (rule hit 65614 success 32)
  match 00001ae0/0000ffe0 at 20 (success 32 ) 
bigismall:~# 
--------------

cheers,
jamal

