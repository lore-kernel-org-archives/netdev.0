From: Ben Greear <greearb@candelatech.com>
Subject: Re: Network virtualization/isolation
Date: Sun, 26 Nov 2006 11:41:50 -0800
Message-ID: <4569EDFE.2020003@candelatech.com>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com> <20061026085659.33b4c6dd@freekitty> <200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com> <1162391707.5251.78.camel@jzny2> <m1bqmwos18.fsf@ebiederm.dsl.xmission.com> <20061126183402.GA17878@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, hadi@cyberus.ca,
	Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:24031 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1756462AbWKZTlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Nov 2006 14:41:16 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061126183402.GA17878@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> On Sat, Nov 25, 2006 at 01:21:39AM -0700, Eric W. Biederman wrote:
>   
> Then the question is how do we reduce the overhead when we don't have
>> enough physical network interfaces to go around.  My feeling is that
>> we could push the work to the network adapters and allow single
>> physical network adapters to support multiple network interfaces, each
>> with a different link-layer address.  
>>     
>
> that would be something interesting, but again, the
> number of nics allowing for an arbitrary number of
> filters, which also can be identified/correlated to
> the network context without adding even more overhead
> is probably insignificant ... so IMHO that would:
>
>  - keep all interfaces in promisc mode
>  - check each packet for the set of MACs
>
> as the checks would require to identify the interface,
> that would immediately result in O(N) overhead for
> each packet received, plus the overhead added by
> disabling the hardware filters ... but maybe that
> changed over the years, I'm definitely no network
> stack/device expert ...
>   
This can be implemented similar to how MAC-VLANs are currently done (in 
my out-of-tree patch).
There is a performance hit with lots of virtual interfaces (maybe 10% in 
some cases), but this is still
greater than 500Mbps full-duplex on 2 ports on a modern dual-core machine.

I don't even have hashing implemented, but it could be easily added and 
that should
significantly decrease the search time from O(n) to something 
approaching O(1)
in the normal case.

This should also be an easy feature for NICs to add, and just as with 
802.1Q VLANs, when
hardware support is available, the features can migrate into the NIC, 
with the software
mac-vlan logic handling generic hardware.

In a switched environment, going into PROMISC mode should not add any
significant overhead..

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


