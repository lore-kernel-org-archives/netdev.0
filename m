From: Patrick McHardy <kaber@trash.net>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Fri, 24 Apr 2009 17:29:05 +0200
Message-ID: <49F1DAC1.5030809@trash.net>
References: <20090423084323.GA5696@ff.dom.local> <beb91d720904231632m2a66768dy95f1df1491d97f5b@mail.gmail.com> 	<49F1D16A.8050003@trash.net> <200904241755.09198.denys@visp.net.lb> 	<beb91d720904240814x56a928a5u5345e572c701fa90@mail.gmail.com> 	<49F1D88F.500@trash.net> <beb91d720904240823lf724b9bo207f4294dc9e4a8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Salatiel Filho <salatiel.filho@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47632 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbZDXP3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 11:29:11 -0400
In-Reply-To: <beb91d720904240823lf724b9bo207f4294dc9e4a8d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salatiel Filho wrote:
> On Fri, Apr 24, 2009 at 12:19, Patrick McHardy <kaber@trash.net> wrote:
>> Salatiel Filho wrote:
>>> I am just curious , is there a qdisc in mainline that behaves similar
>>> to wrr [weight round robin] ?
>>> http://www.zz9.dk/wrr
>> DRR. But it can't do those strange load-balancing hacks.
>>
> 
> what would it be those strange ugly hacks ? :)

Look at the code. At least they were there last time I had a look.

> Any good place where i can find DRR documentation/examples ?

No, but I can give you an example:

tc qdisc add dev <dev> parent <parent> handle <handle> drr

tc class add dev <dev> parent <handle> classid <classid> drr

repeat class add as often as you need. The default quantum per
class is the MTU, including link layer headers. You can manually
change that by specifying the "quantum" parameter for classes.

As for the flow classifier:

tc filter add dev <dev> protocol all pref 1 parent <handle> \
	flow hash keys key1,key2,... divisor <number of classes>

The DRR classids need to be consequitive for this to work.
