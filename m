From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 16:42:11 -0800
Message-ID: <424C98E3.4040700@hp.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net>	<1112303431.1073.67.camel@jzny.localdomain>	<424C6A98.1070509@hp.com>	<1112305084.1073.94.camel@jzny.localdomain>	<424C7CDC.8050801@hp.com> <424C81B8.6090709@us.ibm.com>	<424C8790.6060203@hp.com> <20050331161016.73181997@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
In-Reply-To: <20050331161016.73181997@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>Well, I'm in an email discussion with someone who seems to bump their TCP 
>>windows quite large, and disable timestamps...
> 
> 
> And do they like the resulting data corruption.

Minor nit - potential data corruption, perhaps even probable, but I don't think 
they are all that concerned yet - feeling secure in their belief that 2*MSL on a 
LAN is rather short indeed, and perhaps even in WANs where using 1GB TCP windows 
(although I may have mixed too much together there).

Of course, if we believe that stacks should be smart enough to limit the initial 
receive windows (or does a setsockopt() actrually override that?), and grow them 
over time based on what the transfer rates might be and the like, perhaps the 
stack should have a hard interlock on TCP window >= 65535 and timestamp option 
on.  No timestamps, no window > 65535 bytes. At present, it seems possible to 
have one without the other.  Of course, if one is indeed on a "LAN" and _knows_ 
(somehow, given the existence of remote bridges) that it is a LAN.

rick jones
