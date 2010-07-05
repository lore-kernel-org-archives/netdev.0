From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Mon, 05 Jul 2010 12:04:31 -0600
Message-ID: <4C321EAF.9000508@redfish-solutions.com>
References: <4C2F7A55.5090700@redfish-solutions.com> <2md4g7-3s3.ln1@chipmunk.wormnet.eu> <4C2FC2C8.8080203@redfish-solutions.com> <20100703234813.GJ24655@chipmunk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:46950 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752043Ab0GESEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:04:40 -0400
In-Reply-To: <20100703234813.GJ24655@chipmunk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/10 5:48 PM, Alexander Clouter wrote:
> Hi,
>
> * Philip Prindeville<philipp_subx@redfish-solutions.com>  [2010-07-03 17:07:52-0600]:
>    
>> On 7/3/10 12:55 PM, Alexander Clouter wrote:
>>      
>>>
>>>        
>>>> Does anyone else think that setsockopt(IP_TOS) should be a privileged
>>>> operation, perhaps using CAP_NET_ADMIN, or maybe even adding separate
>>>> granularity as CAP_NET_TOS?
>>>>
>>>>
>>>>          
>>> I really would prefer not having to run telnet and ssh *clients* as
>>> root. :)
>>>        
>> Don't ping and traceroute -I currently run as root?
>>
>>      
> Indeed, but I have no idea what that has to do with ToS/DSCP flags?
>    

The logic being that if having a RAW socket requires privilege, but it's 
necessary to have reasonable security for user-invokable programs... and 
we manage to do this without too much trouble for those to programs, 
then it shouldn't be an undue hardship to do the same for ssh.

> ping and (old skool) traceroute use ICMP where you need to open a
> privileged socket; to send and receive ICMP packets.  Opening a UDP/TCP
> is an unprivileged operation and so is setsockopt(IP_TOS).
>    

Right.  And I'm saying because of the potentially disruptive nature of 
setsockopt(IP_TOS), perhaps it should require privilege.


> I'm guessing, if you excuse me Google-stalking you), this is all linked
> to:
>
> https://bugzilla.mindrot.org/show_bug.cgi?id=1733
>    

That would be a very good guess.

And google-stalking is fine.  I draw the line at leaving dead cats at my 
front door.


> You have to bear in mind ToS is a marking that userland can utilise to
> request that the network provides it with a particular QoS, this does
> not mean for an instant the network has to honour that (I know my ISP
> does not and neither does my work network I sysadmin for)...otherwise
> nothing would stop me using:
>    

I understand that.  That's part of the reason that I've submitted 
patches for APR, Apache, Thunderbird, Firefox, Proftpd, Curl, wget, 
etc.  There is pressure within certain technical groups to get ISP's to 
voluntarily implement RFC-4594... that's the carrot.  The stick being 
FCC heavy-handed regulation of the ISP's if they don't.

Once QoS markings actually *are* implemented in carrier networks, the 
potential for abuse is non-insignificant.  Hence the suggestion to make 
it privileged.


> iptables -t mangle -I POSTROUTING -j DSCP --set-dscp-class EF
>    

Except that "iptables" is also a privileged operation.


> QoS is meaningless unless you place boundaries on the policies; the
> ToS/DSCP marking should only be used as a *hint* for classification of
> traffic flows.
>    

Like I said, there's an effort to push the ISP's into implementing 
RFC-4594 widespread.  Their previous arguments for not doing so were (a) 
most software doesn't implement QoS (hence the scrub I did above), and 
(b) there were no standard markings.  RFC-4594 attempts to impose a 
standard.


> For example, 'interactive' and 'low latency' (in the case of SSH or
> telnet) should not exceed 10kB/s...unless you like to play 0verkill :)
> Anything marking it's traffic as interactive but shutting traffic at
> 500kB/s is obviously telling lies.  If you build your policing rules to
> blindly accept whatever is in the ToS/DSCP field, you are configuring a
> DoS vector on your network.
>
> Cheers
>
>    

When you say "interactive" and "low latency" are you referring to the 
RFC-791 mappings for those, or to the RFC-4594 mappings of those classes?

Here we use Arno's Iptables Firewall with the traffic-shaper plugin I 
wrote.  This does shaping and policing within traffic classes.

And yes, doing an out-of-the-box shaper for Fedora is on my TODO list.

-Philip

