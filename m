From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 07/20] net: dsa: list ports in switch\\
Date: Thu, 28 Apr 2016 11:29:32 -0700
Message-ID: <5722568C.8000003@gmail.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1461796217-18893-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20160427231537.GJ29024@lunn.ch> <572241BB.1070304@gmail.com>
 <871t5pr3zm.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33587 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbcD1Sbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 14:31:52 -0400
In-Reply-To: <871t5pr3zm.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/04/16 11:18, Vivien Didelot wrote:
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> On 27/04/16 16:15, Andrew Lunn wrote:
>>> On Wed, Apr 27, 2016 at 06:30:04PM -0400, Vivien Didelot wrote:
>>>> List DSA port structures in their switch structure, so that drivers can
>>>> iterate on them to retrieve information such as their ports membership.
>>>
>>> And this would be so much easier using a plan array.
>>
>> Agreed, I do not see much value in doing this at the moment. Even if you
>> have unused ports in a switch, allocating an array is a small price to
>> pay compared to directly indexing by port number.
>>
>> NAK from me unless there is a compelling reason for doing so.
> 
> The point of having a list is 1) get rid of the DSA_MAX_PORTS and have
> variable number of ports 2) lists make iteration easier with variable
> number of switchs/ports, e.g.:

You could get rid of the DSA_MAX_PORTS by asking switch drivers how many
ports they support and allocate that dynamically.

> 
>     dsa_tree_for_each_switch(dst, ds)
>         dsa_switch_for_each_port(ds, dp)
>             /* do something with the port */;

This is not more compact or efficient than an array walk, but at this
point this becoming preference over anything.

> 
> Anyway, I'm writing a proposal for a new design of DSA, in order to
> support the D in DSA. That way, we'll avoid reviewing details of the
> implementation and have a big picture of the necessary API changes.

Quite frankly, I think your set of changes are submitted at a terrible
time, I would very much prefer to allow Andrew to complete his work on
re-designing the DSA layer to allow different kinds of switches, thus
allowing other people to support more HW in a blink of an eye, and
therefore allowing us all to get a clearer picture of what these little
switches are capable, rather than some patches that produce a lot of
churn with little documented benefits outside of the cross-chip operations.

Don't get me wrong, I think we should get to the point where you want us
to go, and work in that area is very much appreciated!

Thanks
-- 
Florian
