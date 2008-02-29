From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH (resend)][EBTABLES]: Fix alignment checks in ebt_among.ko
 module.
Date: Fri, 29 Feb 2008 16:40:24 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802291639390.24056@fbirervta.pbzchgretzou.qr>
References: <47C7C23C.2050100@openvz.org> <47C7FF31.1060108@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Bart De Schuymer <bdschuym@pandora.be>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47C7FF31.1060108@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 29 2008 13:48, Patrick McHardy wrote:
> Pavel Emelyanov wrote:
>> I've sent this patch some days ago to Bart, but with no answer...
>> 
>> When trying to do
>> 
>>  # ebtables -A FORWARD --among-src 0:12:34:56:78:9a=192.168.0.10 -j ACCEPT
>> 
>> on x86_64 box the ebt_among->check() callback warns me that
>> 
>>  ebtables: among: wrong size: 1060 against expected 1056, rounded to 1056
>> [...]
>
> It seems the kernel is correct and userspace is doing it
> wrong, so I think userspace should be fixed instead.
> The problem with your patch is that is causes misalignment
> for following structures that contain u64 members.

ebt_among is a true mess! It hinders my efforts to port ebtables
to xtables, but I could of course use a hack and will likely
do just that.
