From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: net: replace hooks in __netif_receive_skb (v4)
Date: Wed, 2 Jun 2010 09:02:33 +0200
Message-ID: <20100602070232.GB2603@psychotron.redhat.com>
References: <20100527180813.GA3714@psychotron.redhat.com>
 <20100527130822.02cb1661@nehalam>
 <20100528055154.GB2823@psychotron.redhat.com>
 <20100528061241.GC2823@psychotron.redhat.com>
 <1275030163.2650.3.camel@edumazet-laptop>
 <20100528073345.GD2823@psychotron.redhat.com>
 <20100601082805.1c84b16d@nehalam>
 <20100601154106.GA4929@psychotron.redhat.com>
 <20100601091004.7885cd8c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	eric.dumazet@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755733Ab0FBHCj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 03:02:39 -0400
Content-Disposition: inline
In-Reply-To: <20100601091004.7885cd8c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 01, 2010 at 06:10:04PM CEST, shemminger@vyatta.com wrote:
>On Tue, 1 Jun 2010 17:41:07 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> Actually, I'm not happy about this (reducing to only one hook) and for two
>> reasons:
>> 
>> 1) I think it's a good behaviour to "mask" one handler by another in case device
>> is for example used for macvlan and then added to bridge. Because when it's
>> again removed from the bridge, the original functionality is restored. And also,
>> this would be consistent with the current behaviour.
>> 
>> 2) I would imagine a situation, when multiple handers are needed in cascade.
>> Actually I'm working on a virtual device draft which uses two handlers, although
>> in corner situation.
>> 
>> Regards,
>> 	Jirka
>
>I don't like it because:
>
>1) Adding macvlan to bridge makes no sense. The bridge is already in promicious mode.

Right, I'm not saying it has sense to have it together in the same moment. But
you can to this:

# ip link add link eth0 type macvlan

You can use eth0 + macvlan0. Now you do:

# brctl addif br0 eth0

Direct use of eth0 and macvlan0 is not not possible now.

# brctl delif br0 eth0

Now the original functionality ot eth0 and macvlan0 is restored.

>
>2) I don't like to see functionality added when it is not needed.
>
>3) The extra overhead of traversing list causes more cache activity in extreme
>   hot path.
>

But ok, I hear your arguments, I thought about them myself before I did the
patch and I thought that added overhead (which is not too big, I see one more
dereference, rx_handler pointer) would be acceptible.

Maybe someone other then us has opinion too :)

>Wait and add the multiple handlers when your code is included.
>
>-- 
>http://www.extremeprogramming.org/rules/early.html
