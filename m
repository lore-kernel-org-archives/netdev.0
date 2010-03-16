From: Julien Vehent <julien@linuxwall.info>
Subject: Re: TBF parameters: overhead and linklayer =?UTF-8?Q?=20=3F?=
Date: Tue, 16 Mar 2010 11:21:34 +0100
Message-ID: <398abc5c97bf8b552252ad85cda742cf@localhost>
References: <7370d7aa62d806f62f2a22b4095dd0ec@localhost> <cone.1268730409.349704.27722.1001@bork.lsof.org> <4b0881d1e12a25816f9efac65c4c54ec@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Roel van Meer <rolek@bokxing.nl>, <ahu@ds9a.nl>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:36283 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966062Ab0CPKVn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 06:21:43 -0400
In-Reply-To: <4b0881d1e12a25816f9efac65c4c54ec@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gotcha !

in iproute2-2.6.33/tc/tc_util.c

442 int get_linklayer(unsigned int *val, const char *arg)
443 {
444         int res;
445  
446         if (matches(arg, "ethernet") == 0)
447                 res = LINKLAYER_ETHERNET;
448         else if (matches(arg, "atm") == 0)
449                 res = LINKLAYER_ATM;
450         else if (matches(arg, "adsl") == 0)
451                 res = LINKLAYER_ATM;
452         else 
453                 return -1; /* Indicate error */ 
454  
455         *val = res;
456         return 0;
457 }

Now, if I try this, it works:

ses0gnoc:~# tc qdisc add dev eth0 root tbf rate 1mbit burst 10000 latency
10ms linklayer atm

ses0gnoc:~# tc -s qdisc show dev eth0
qdisc tbf 8004: root rate 1000Kbit burst 10000b lat 10.0ms
 Sent 754 bytes 5 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0


No ongoing taskforce to rewrite those manpages ? TC is a great tool, but
documentation severely suck...



On Tue, 16 Mar 2010 11:03:28 +0100, Julien Vehent <julien@linuxwall.info>
wrote:
> Thanks Roel,
> 
> I then found this wwebsite from your link http://www.adsl-optimizer.dk
> 
> I'm trying to find more information on how to use this... documentation
is
> really not easily accessible.
> 
> (currently reading latest iproute2 source code available)
> 
> On Tue, 16 Mar 2010 10:06:49 +0100, Roel van Meer <rolek@bokxing.nl>
> wrote:
>> Julien Vehent writes:
>> 
>>> TC_TBF man page seem outdated (even in latest version of iproute2) and
>>> doesn't explain what those two parameters do:
>>> 
>>> # tc qdisc add tbf help
>>> Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS [ mtu
>>> BYTES[/BYTES] ]
>>>         [ peakrate KBPS ] [ latency TIME ] [ overhead BYTES ] [
> linklayer
>>> TYPE ]
>>> 
>>> 
>>>  - overhead ?
>>>  - linklayer ?
>>> 
>>> Or did I miss something ?
>> 
>> No, you're right. You might want to have a look at this page:
>> http://ace-host.stuart.id.au/russell/files/tc/tc-atm/
>> 
>> Regards,
>> 
>> roel
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
