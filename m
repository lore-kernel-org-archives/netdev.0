From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 19:29:44 -0500
Message-ID: <49D406F8.40606@codemonkey.ws>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:56497 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992AbZDBA3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 20:29:50 -0400
In-Reply-To: <49D3D7EE.4080202@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins wrote:
> Anthony Liguori wrote:
>   
> I think there is a slight disconnect here.  This is *exactly* what I am
> trying to do. 

If it were exactly what you were trying to do, you would have posted a 
virtio-net in-kernel backend implementation instead of a whole new 
paravirtual IO framework ;-)

>> That said, I don't think we're bound today by the fact that we're in
>> userspace.
>>     
> You will *always* be bound by the fact that you are in userspace.

Again, let's talk numbers.  A heavy-weight exit is 1us slower than a 
light weight exit.  Ideally, you're taking < 1 exit per packet because 
you're batching notifications.  If you're ping latency on bare metal 
compared to vbus is 39us to 65us, then all other things being equally, 
the cost imposed by doing what your doing in userspace would make the 
latency be 66us taking your latency from 166% of native to 169% of 
native.  That's not a huge difference and I'm sure you'll agree there 
are a lot of opportunities to improve that even further.

And you didn't mention whether your latency tests are based on ping or 
something more sophisticated as ping will be a pathological case that 
doesn't allow any notification batching.

> I agree that the "does anyone care" part of the equation will approach
> zero as the latency difference shrinks across some threshold (probably
> the single microsecond range), but I will believe that is even possible
> when I see it ;)
>   

Note the other hat we have to where is not just virtualization developer 
but Linux developer.  If there are bad userspace interfaces for IO that 
impose artificial restrictions, then we need to identify those and fix them.

Regards,

Anthony Liguori

> Regards,
> -Greg
>
>   

