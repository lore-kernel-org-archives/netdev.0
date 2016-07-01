From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] bridge: vlan: add support to display
 per-vlan statistics
Date: Fri, 1 Jul 2016 11:24:16 +0200
Message-ID: <577636C0.7080403@cumulusnetworks.com>
References: <1466417599-12940-1-git-send-email-nikolay@cumulusnetworks.com>
 <20160621090141.0c13d12d@xeon-e3> <57696709.7010506@cumulusnetworks.com>
 <5769674F.3090700@cumulusnetworks.com> <20160630170659.07f46c3c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36628 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbcGAJwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:52:06 -0400
Received: by mail-wm0-f47.google.com with SMTP id f126so19490898wma.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 02:52:05 -0700 (PDT)
In-Reply-To: <20160630170659.07f46c3c@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/16 02:06, Stephen Hemminger wrote:
> On Tue, 21 Jun 2016 18:11:59 +0200
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>>>> Thanks, this is a useful tool, but I think the formatting of output may need to be
>>>> reworked.  The bridge tool works similar to ip command. And in the ip command the
>>>> -s flag causes additional lines, but does not change the output format.  
>>>
>>> Indeed, I agree that it needs refinement.
>>>   
>>
>> Or alternatively I can make it:
>> $ bridge vlan stats
>> a subcommand instead of using the "-s" argument in order to be consistent.
>> So it can have its own format.
> 
> Why not:
> 
> $ bridge -s vlan show
> 
> to be consistent with:
> 
> $ ip -s li show
> 

The problem is that currently it cannot be formated the same as "bridge vlan show"
because it cannot contain the flags since all vlan stats are fetched from the
bridge device even though some vlans might exist only on the ports (or have different
flags on the ports).
That might change soon though, if my IGMP stats patches are accepted we'll be able
to fetch the vlan stats per port as well and thus print the flags and make the
output consistent with "bridge vlan show". Thus my first version of this patch that
just printed the stats will work in that case, we'll just add the flags and port
output later. If you'd like to go down this road please let me know.

Me and Roopa have been discussing an alternative way to fetch the stats via a new
command, something like:
$ bridge stats { <igmp> | <vlan> } [ dev DEV ] [ vid VID ]
because of the IGMP/MLD stats which don't fit any of the other commands for a "-s"
flag.

What do you think ?

Cheers,
 Nik
