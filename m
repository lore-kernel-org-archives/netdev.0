From: Mr Dash Four <mr.dash.four@googlemail.com>
Subject: Re: [patch 2/4] ipset: make IPv4 and IPv6 address handling similar
Date: Tue, 18 Jan 2011 22:49:21 +0000
Message-ID: <4D3618F1.2040409@googlemail.com>
References: <20110118142154.697547841@eitzenberger.org> <20110118142247.498399684@eitzenberger.org> <alpine.DEB.2.00.1101182116150.28203@blackhole.kfki.hu> <alpine.LNX.2.01.1101182121310.19007@obet.zrqbmnf.qr> <alpine.DEB.2.00.1101182128210.28350@blackhole.kfki.hu> <alpine.LNX.2.01.1101182139030.19166@obet.zrqbmnf.qr> <20110118214343.GA4845@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@medozas.de>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110118214343.GA4845@mail.eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> You shouldn't use hash:ip with ranges for IPv4 too because the range
> members are added individually, which is less efficient both memory
> and performance wise, see:
>
>  $ ipset create foo hash:ip hashsize 64
>  $ ipset add foo 192.168.1.0/30
>  $ ipset list foo
>  Name: foo
>  Type: hash:ip
>  Header: family inet hashsize 64 maxelem 65536 
>  Size in memory: 628
>  References: 0
>  Members:
>  192.168.1.3
>  192.168.1.2
>  192.168.1.0
>  192.168.1.1
>   
I disagree!

If I need to add the 192.168.1.0/30 then I have to execute a loop (via a 
script) and add individual elements (i.e. ipset add foo 192.168.1.0, 
ipset add foo 192.168.1.1 etc).

By specifying ipset add foo 192.168.1.0/30 I do that in one go. Even 
though I am inclined to agree that storing individual elements may not 
be the best way memory/storage wise I think performance wise (i.e. when 
the actual matching is performed) it is better matching a single IP 
address than IP range.

