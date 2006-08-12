From: Ben Greear <greearb@candelatech.com>
Subject: Re: Stackable devices.
Date: Sat, 12 Aug 2006 11:43:58 -0700
Message-ID: <44DE216E.4020609@candelatech.com>
References: <44CA34D0.1070507@candelatech.com> <20060808120307.GA17547@walrus.eth1.org> <44D8BD99.1090505@candelatech.com> <200608091557.09249.Christophe.Devriese@eurid.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:13219 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1422646AbWHLTeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 15:34:09 -0400
To: Christophe Devriese <Christophe.Devriese@eurid.eu>
In-Reply-To: <200608091557.09249.Christophe.Devriese@eurid.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe Devriese wrote:
> It would however be considerable effort to do this. Is this going to end up 
> unapplied like my last patch, or ?

I don't get to make this decision..and when I ask such questions...they
are usually ignored unless I also post a working patch....

I think you could start with just supporting bridging without too
much code.

Ben

> 
> Regards,
> 
> Christophe
> 
> On Tuesday 08 August 2006 18:36, you wrote:
> 
>>Christophe Devriese wrote:
>>
>>>On Wed, Aug 02, 2006 at 10:50:08AM -0700, Ben Greear wrote:
>>>
>>>>Currently, the bridge hook logic is something like:
>>>>
>>>>if (bridge-consumed-pkt) {
>>>>	return
>>>>}
>>>>
>>>>// drop through to other layers
>>>>
>>>>
>>>>There are several other hooks I'd like to see added (pktgen receive
>>>>processing,
>>>>mac-vlans, etc).  Each of these hooks are logically similar to the bridge
>>>>hook,
>>>>ie if it consumes the pkt, return, else, drop through to the next hook
>>>>untill
>>>>we get to the regular protocol processing logic.
>>>>
>>>>I would like to be able to chain layer-2 handlers, such as bridge,
>>>>mac-vlan, pktgen such that if one consumed, you break out of the
>>>>handling, else, you try the next handler.  The handlers can be
>>>>dynamically registered and inserted
>>>>in any order, controllable by user-space and/or module load/unload.
>>>>
>>>>For many of the handlers, the logic will re-insert the packet by
>>>>re-calling the
>>>>netif-rx logic, so there would need to be some protection to keep loops
>>>>from occurring that would recurse too much and overflow the stack.
>>>
>>>I'm also a big fan of a generalized system like this. It would need to
>>>catch both the vlan accelerated path and the normal path.
>>
>>Well, it isn't actually needed for VLANs since VLAN's hook is a protocol
>>handler....
>>
>>Ben
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


