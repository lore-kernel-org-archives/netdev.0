From: Rick Jones <rick.jones2@hp.com>
Subject: Re: VxLAN system wedge in 4.0.0-rc5+ from davem net-next?
Date: Tue, 07 Apr 2015 10:17:14 -0700
Message-ID: <5524111A.80408@hp.com>
References: <551F2C20.1060908@hp.com> <20150406190743.GA3969@localhost.localdomain> <5522E5F5.7050605@hp.com> <55230E02.2060204@hp.com> <1428401693.3914618.250169009.7869259D@webmail.messagingengine.com> <1428409685.3947287.250212889.1919258C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hp.com ([15.240.92.66]:58648 "EHLO
	g9t5008.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbbDGRRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 13:17:16 -0400
In-Reply-To: <1428409685.3947287.250212889.1919258C@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2015 05:28 AM, Hannes Frederic Sowa wrote:
> On Tue, Apr 7, 2015, at 12:14, Hannes Frederic Sowa wrote:
>> On Tue, Apr 7, 2015, at 00:51, Rick Jones wrote:
>>> The git bisect has implicated:
>>>
>>> b6a7719aedd7e5c0f2df7641aa47386111682df4 is the first bad commit
>>> commit b6a7719aedd7e5c0f2df7641aa47386111682df4
>>> Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> Date:   Wed Mar 25 17:07:44 2015 +0100
>>
>> Thanks for the report, I try to reproduce this right now!
>
> Rick, can you send me more details on your setup? I am not able to
> reproduce it here, I am able to send a lot of fragments via vxlan
> interfaces here.

Pair of HP Sl230s Gen8 systems with HP 560FLR 10GbE NICs (Intel
82599ES) connected to an HP 5900 series switch running Comware 7.11.035, 
Release 2208P01.  On one side I have a 3.14.mumble kernel (which was 
also the source of the config file used to build the upstream kernels). 
  On the other side I have the test kernels from davem's net-next tree. 
  I create the vxlan0 interface using:

  ip li add vxlan0 type vxlan id 42 group 239.1.1.1 dev eth2 dstport 4789

Which is taken almost verbatim from Documentation/networking/vxlan.txt
and then I assign an IP address to the interface with ifconfig.  Then I 
ping the other system (which I have setup vxlan similarly) and before I 
even see ping report one reply, the system ceases to respond via the 
network or console.

I suspect my present mail client would munge it as inline so I'll send 
you a copy of the config file as a direct email with an attachment.

rick
