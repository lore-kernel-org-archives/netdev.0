From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 10:27:40 -0400
Message-ID: <482D99DC.7040501@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	 <20080515142154.0595e475@core>	 <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>	 <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com>	 <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com>	 <482C8D4D.3040702@garzik.org>	 <20080516132107.GA11304@csclub.uwaterloo.ca>	 <482D8EE9.10404@garzik.org> <87a5b0800805160659j1e8482efjea2fb8167f755e05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Will Newton <will.newton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39700 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393AbYEPO1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 10:27:51 -0400
In-Reply-To: <87a5b0800805160659j1e8482efjea2fb8167f755e05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will Newton wrote:
> On Fri, May 16, 2008 at 2:40 PM, Jeff Garzik <jeff@garzik.org> wrote:
>> Lennart Sorensen wrote:
>>> On Thu, May 15, 2008 at 03:21:49PM -0400, Jeff Garzik wrote:
>>>> "no other form of entropy"?   See examples in this thread.
>>> So where does one get entropy if not the ethernet adapter on many
>>> embedded systems?  If you have no mouse, no keyboard, no hardware number
>>> generator, just ethernet ports and a serial console that usually
>>> receives no input.  While ethernet might not be preferable if you have
>>> something else, sometimes you really don't have anything else.
>> Already answered in this thread...  EGD illustrates how many sources of
>> entropy remain, even in the example you just gave.
>>
>> Further, you do not want to rely on entropy from a source that declines just
>> as network traffic increases.
> 
> I don't know egd that well, but from a cursory look it gets data from
> such things as w or last (wtmp) which is static on most embedded
> boxes.

Inevitably some of the local-machine entropy sources will be static or 
externally influenced.  That's the whole point of using several.  If 
using one source was sufficient... we would just use that one and be 
done with it.  :)

The questions to ask are

* is this collective snapshot of local machine state sufficiently unique?

* is this local-machine state externally controllable within realistic 
orders of complexity?


> It also uses netstat and snmp - surely this is at least as easy
> to manipulate as interrupt timings?

netstat reflects local machine state of all sockets, including local 
ones, and including local details like tcp in-q and out-q.  snmp can 
query MIBs such as ethernet wire stats, gaining entropy from 
pause/collision/etc. frame statistics.

A set of mitigated network interrupt events is far, far more predictable 
and controllable than the collective state of a machine's network 
sockets, or the electrical state of the ethernet LAN link.

For network-interrupt randomness to be subverted in some cases, one 
might need only to increase overall network traffic to a certain level.

	Jeff


