From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: VRF_DEVICE integration plan
Date: Sun, 24 Apr 2016 17:30:40 -0600
Message-ID: <571D5720.7000908@cumulusnetworks.com>
References: <AT5PR84MB00652788CA3C3F63146F9C08CA610@AT5PR84MB0065.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "Elluru, Krishna Mohan" <elluru.kri.mohan@hpe.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35910 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbcDXXao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 19:30:44 -0400
Received: by mail-ig0-f178.google.com with SMTP id f1so61638228igr.1
        for <netdev@vger.kernel.org>; Sun, 24 Apr 2016 16:30:43 -0700 (PDT)
In-Reply-To: <AT5PR84MB00652788CA3C3F63146F9C08CA610@AT5PR84MB0065.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/23/16 10:07 PM, Elluru, Krishna Mohan wrote:
> HI Netdev team,
>
>   	Greetings. We have been monitoring the vrf device approach for l3 isolation from cumulus networks and we are currently interested in validating it. We have following questions on them and hoping to get answers from you/concerned team.
>
> 1. As per the linux documentation, there are known limits on if_index lookup, as the incoming if_index is changed to vrf_device index and thus an application receiving this packet will perceive this as a vrf_device packet, than right if_index. I saw you mentioned about a special flag to identify the origin, but didn't see the same in the latest linux 4.4.2 version code. Is there a patch expected for it?

you are referring to IP{6}_PKTINFO? I have patches from our 4.1 kernel 
tree that I have rebased to top of tree. I hope to send those out in the 
next few weeks.

>
> 2. What are the future additions planned for this approach? Are there any ipv4 and ipv6 known bugs with vrf_device model?

We have about 20 patches in our tree that I have not sent upstream yet. 
Those patches fix PKTINFO, allow local traffic (e.g, ping in a VRF to a 
local address in a VRF), allow IPv6 multicast and linklocal traffic, and 
the cgroup implementation which has been sent as an RFC.

I posted a few bug fix patches a week or two ago. Not sure what the 
status is with respect to 4.3 - 4.5 trees.

>
> 3. It has been said in the documentation that, with addition of cgroup functionality for vrf device, with net_admin capabilities, we should be able to add an interface to vrf_device, currently it is not so. Any timelines on these?

I don't understand that question. The current implementation allows 
adding interfaces (netdev's) to a VRF. The cgroup allows running a 
process in a VRF context such that AF_INET{6} sockets are automatically 
bound to the VRF device.

>
> 4. Currently the changes are available and portable from 4.3.x onwards. Is there a plan to port them to previous kernel versions?

no. Anyone wanting to use the vrf patches on other kernel versions will 
need to port them.

>
> 5. Is there a possibility of enabling secondary level lookup, to give a leak functionality to parent route table from device local route table? I tested with veth pair, configured one as default gateway, it is possible to forward traffic b/w the interfaces, looking for cleaner method.

Are you referring to inter-vrf routing? See slide 27
http://www.netdevconf.org/1.1/proceedings/slides/ahern-vrf-tutorial.pdf

>
> 6. With "VRF Device" in place,  please confirm if there are any plans to add VRF support for applications like
>
> 	1.	Ping

no need. ping{6} -I <vrf device> ...

> 	2.	Traceroute

no need. traceroute{6} -i <vrf device> ...

> 	3.	DNS-Client [glibc]
>
> 	In case of DNS-Client, most of the name resolution APIs will have to consider the VRF to do the lookup in  and the way the domain-name/name-server configuration is stored.

I have looked into it but no patches worth distributing at the moment.
