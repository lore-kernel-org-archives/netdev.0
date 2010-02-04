From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter/iptables and network interface names
Date: Thu, 4 Feb 2010 17:48:03 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1002041743360.21982@obet.zrqbmnf.qr>
References: <4B6AC467.7020209@redhat.com> <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr> <4B6ADA3A.7040201@trash.net> <alpine.LSU.2.01.1002041542150.13435@obet.zrqbmnf.qr> <4B6ADFFB.4050407@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Woerner <twoerner@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B6ADFFB.4050407@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-02-04 15:55, Patrick McHardy wrote:

>>>>> What do you think?
>> 
>> When was the last time you needed a control character in your
>> interface name?
>
>Actually I did use ansi-colors in my interface names once for fun :)

Madness!

>Anyways, I don't see why iptables should impose arbitrary restrictions.

Well iptables does allow \e!

>> Like this?
>> 
>> @@ -473,12 +473,11 @@ void xtables_parse_interface(const char *arg, char *vianame,
>>  		memset(mask, 0xFF, vialen + 1);
>>  		memset(mask + vialen + 1, 0, IFNAMSIZ - vialen - 1);
>>  		for (i = 0; vianame[i]; i++) {
>> -			if (vianame[i] == ':' ||
>> -			    vianame[i] == '!' ||
>> -			    vianame[i] == '*') {
>> +			if (vianame[i] == '/' ||
>> +			    vianame[i] == ' ') {
>>  				fprintf(stderr,
>>  					"Warning: weird character in interface"
>> -					" `%s' (No aliases, :, ! or *).\n",
>> +					" `%s' ('/' and ' ' are not allowed by the kernel).\n",
>>  					vianame);
>
>The kernel also forbids ".".

My first thought was the same, but:

a) Interestingly, it does not prohibit '.'

	ip tunnel add foo0.3 mode sit local 1.2.3.4 remote 5.6.7.8

b) The '.' is to be seen as valid as far as xtables.c goes, so
   as to match VLAN interfaces.

