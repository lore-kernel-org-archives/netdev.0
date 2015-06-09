From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Weird DHCP related problems with net-next
Date: Tue, 09 Jun 2015 13:31:31 -0700
Message-ID: <55774D23.1010508@gmail.com>
References: <5577367A.50901@gmail.com> <20150609192242.GD16778@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35345 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbbFIUcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 16:32:36 -0400
Received: by qkhq76 with SMTP id q76so15037284qkh.2
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 13:32:35 -0700 (PDT)
In-Reply-To: <20150609192242.GD16778@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 09/06/15 12:22, Andrew Lunn wrote:
> On Tue, Jun 09, 2015 at 11:54:50AM -0700, Florian Fainelli wrote:
>> Hi,
>>
>> I am observing a strange problem on net-next (not observed with net,
>> bisection in progress) where the initial DHCP configuration using
>> busybox's udhcpc is able to configure the local interface address and
>> DNS serer, but not the default gateway. Restarting udhcpc a second time
>> does not exhibit this problem.
> 
> Hi Florian
> 
> I've seen something similar, but different, again with DSA involved,
> on a WiFi Access point. I have debian, and i'm using isc dhcp. It gets
> an address, sets the address on the interface, but does not add the
> interface route to the routing table. Not sure about default route, i
> would have to go check that.

Interesting, did you also observe this with 'net', or just with 'net-next'?

Contrary to what I reported above, this is only an issue with
SYSTEMPORT/DSA/SF2, I could not reproduce this GENET or the Asix driver,
I was just conflating two different systems here.

My bisection seems to point at this commit:

58c2cb16b116d7feace621bd6b647bbabacfa225 ("switchdev: convert
fib_ipv4_add/del over to switchdev_port_obj_add/del")

And indeed, hacking a bit the kernel to remove the SWITCHDEV/DSA
dependencies to leave just DSA makes thing work again.

Scott, Jiri, any clues? I can instrument the kernel a bit more to help
find what is the problem here. Note that I am observing this on ARM
(Andrew probably is as well), where uninitialized stack variables are
potentially garbage.
-- 
Florian
