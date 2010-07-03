From: Alexander Clouter <alex@digriz.org.uk>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Sun, 4 Jul 2010 00:48:13 +0100
Message-ID: <20100703234813.GJ24655@chipmunk>
References: <4C2F7A55.5090700@redfish-solutions.com> <2md4g7-3s3.ln1@chipmunk.wormnet.eu> <4C2FC2C8.8080203@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chipmunk.wormnet.eu ([195.195.131.226]:54774 "EHLO
	chipmunk.wormnet.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118Ab0GCX5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 19:57:08 -0400
Content-Disposition: inline
In-Reply-To: <4C2FC2C8.8080203@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

* Philip Prindeville <philipp_subx@redfish-solutions.com> [2010-07-03 17:07:52-0600]:
>
> On 7/3/10 12:55 PM, Alexander Clouter wrote:
>>    
>>> Does anyone else think that setsockopt(IP_TOS) should be a privileged
>>> operation, perhaps using CAP_NET_ADMIN, or maybe even adding separate
>>> granularity as CAP_NET_TOS?
>>>
>>>      
>> I really would prefer not having to run telnet and ssh *clients* as
>> root. :)
>
> Don't ping and traceroute -I currently run as root?
>
Indeed, but I have no idea what that has to do with ToS/DSCP flags?

ping and (old skool) traceroute use ICMP where you need to open a 
privileged socket; to send and receive ICMP packets.  Opening a UDP/TCP 
is an unprivileged operation and so is setsockopt(IP_TOS).

I'm guessing, if you excuse me Google-stalking you), this is all linked 
to:

https://bugzilla.mindrot.org/show_bug.cgi?id=1733

You have to bear in mind ToS is a marking that userland can utilise to 
request that the network provides it with a particular QoS, this does 
not mean for an instant the network has to honour that (I know my ISP 
does not and neither does my work network I sysadmin for)...otherwise 
nothing would stop me using:

iptables -t mangle -I POSTROUTING -j DSCP --set-dscp-class EF

QoS is meaningless unless you place boundaries on the policies; the 
ToS/DSCP marking should only be used as a *hint* for classification of 
traffic flows.

For example, 'interactive' and 'low latency' (in the case of SSH or 
telnet) should not exceed 10kB/s...unless you like to play 0verkill :)  
Anything marking it's traffic as interactive but shutting traffic at 
500kB/s is obviously telling lies.  If you build your policing rules to 
blindly accept whatever is in the ToS/DSCP field, you are configuring a 
DoS vector on your network.

Cheers

-- 
Alexander Clouter
.sigmonster says: A rolling stone gathers momentum.
