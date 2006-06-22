From: Ryan Pratt <pratt@argus-systems.com>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Thu, 22 Jun 2006 10:57:14 -0500
Message-ID: <449ABDDA.2070606@argus-systems.com>
References: <20060621194234.979661000@flek.zko.hp.com> <20060621200031.589235000@flek.zko.hp.com> <20060622.021223.125894633.davem@davemloft.net> <200606220943.11185.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, redhat-lspp@redhat.com,
	selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org, sds@epoch.ncsc.mil, jmorris@redhat.com,
	sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.argus-systems.com ([66.209.209.162]:29834 "EHLO
	ranger.argus-systems.com") by vger.kernel.org with ESMTP
	id S1751377AbWFVPxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 11:53:07 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <200606220943.11185.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:

>On Thursday 22 June 2006 5:12 am, David Miller wrote:
>  
>
>>From: paul.moore@hp.com
>>Date: Wed, 21 Jun 2006 15:42:38 -0400
>>
>>    
>>
>>The thing that concerns me most about CIPSO is that even once users
>>migrate to a more SELINUX native approach from this CIPSO stuff, the
>>CIPSO code, it's bloat, and it's maintainence burdon will remain.
>>
>>It's easy to put stuff it, it's impossible to take stuff out even
>>once it's largely unused by even it's original target audience.
>>
>>And that's what I see happening here.
>>
>>This is why, to be perfectly honest with you, I'd much rather
>>something like this stay out-of-tree and people are strongly
>>encouraged to use the more native stuff under Linux.
>>    
>>
>
>Well, not exactly the response I was hoping for, but let me plead my case one 
>more time :)
>
>Traditional MLS CIPSO is a niche "protocol", I won't try to argue that point, 
>and I also won't try to argue that the NetLabel patch is late to the party, 
>the IPsec/XFRM labeling approach has already been accepted as "the" SELinux 
>packet labeling mechanism.  However, the XFRM labeling mechanism in not 
>currently supported by any OS other than Linux/SELinux.  I have spoken with 
>users that need CIPSO to interoperate with their other trusted systems, the 
>XFRM approach is simply not a viable solution for them.  I strongly believe 
>that failure to support an interoperable packet labeling mechanism on Linux 
>will seriously restrict Linux's deployment in trusted networks.
>
The PitBull product uses the CIPSO/RIPSO labeling protocol in order to 
do interop packet labeling with other trusted systems and for passing 
labels between our own systems.  Because it is the standard, it is the 
protocol that government agencies use to do packet labeling across 
networks.  Not having CIPSO in the mainline would mean that government 
agencies would either a) only use SELinux from a distro that supports 
the CIPSO patch (by maintaining it in their kernel themselves), if such 
a distro exists, b) have to patch the kernels themselves (unlikely), or 
c) not use SELinux at all.

Also, the port of PitBull to Linux that I'm working on is currently 
using the netlabel patch to handle the CIPSO/RIPSO labeling.  Since the 
actual protocol for reading and writing out the IPSec option is 
independent from the security enforcment module it makes a lot of sense 
to have a generic handler in the kernel that LSM modules can use.  So, 
in short, it makes my life a lot easier to have all that work already 
done :)

-- 
Ryan Pratt
Chief Solaris Engineer
Innovative Security Systems, Inc.
(dba Argus Systems Group)
1809 Woodfield Dr.
Savoy IL 61874
(217) 355-6308
www.argus-systems.com


