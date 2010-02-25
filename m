From: Reinaldo de Carvalho <reinaldoc@gmail.com>
Subject: Re: [Bugme-new] [Bug 15379] New: u32 classifier port range
	calculation error
Date: Thu, 25 Feb 2010 16:11:49 -0300
Message-ID: <4a5881461002251111r654b6f90l42a4d596125cb796@mail.gmail.com>
References: <bug-15379-10286@http.bugzilla.kernel.org/>
	 <20100224145220.da5ec0b0.akpm@linux-foundation.org>
	 <1267068257.3973.865.camel@bigi>
	 <4a5881461002250325o45965b2fu2855b712b73e00b9@mail.gmail.com>
	 <1267104293.3973.947.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:53281 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932804Ab0BYTML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 14:12:11 -0500
Received: by gwj16 with SMTP id 16so1905674gwj.19
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 11:12:10 -0800 (PST)
In-Reply-To: <1267104293.3973.947.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2010 at 10:24 AM, jamal <hadi@cyberus.ca> wrote:
> On Thu, 2010-02-25 at 08:25 -0300, Reinaldo de Carvalho wrote:
>> Then u32 mask is useless. Or exist a correct mask to match with especific range?
>
> Ranges and masks typically dont mix well generally - this has nothing to
> do with u32; try doing subnet ranges for example. It is hard to describe
> port range 10->20 using masks..
>
> If i read your email correctly: you are trying to get the first 32 ports
> after 6880. It would seem to me the mask should be 0xFFE0, no? i.e your
> bc calculation should be:
> echo "obase=16;(2^16)-32" | bc
>

No.

Testing with mask 0xFFE0... (1 port match)

# Stats...
# tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht
800 bkt 0 flowid 1:1200  (rule hit 13 success 0)
  match 00001ae0/0000ffe0 at 20 (success 0 )

# Sending packets...
# nmap example.ufpa.br -p 1-65535

# Stats...
# tc -s filter show dev eth0
filter parent 1: protocol ip pref 1 u32
filter parent 1: protocol ip pref 1 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 1 u32 fh 800::800 order 2048 key ht
800 bkt 0 flowid 1:1200  (rule hit 65459 success 1)
  match 00001ae0/0000ffe0 at 20 (success 1 )




-- 
Reinaldo de Carvalho
http://korreio.sf.net
http://python-cyrus.sf.net

"Don't try to adapt the software to the way you work, but rather
yourself to the way the software works" (myself)
