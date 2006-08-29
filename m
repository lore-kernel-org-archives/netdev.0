From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/6] NetLabel: correctly initialize the NetLabel fields
Date: Tue, 29 Aug 2006 16:21:52 -0400
Message-ID: <44F4A1E0.4000307@hp.com>
References: <20060829144251.452774000@hp.com> <20060829144444.202106000@hp.com> <Pine.LNX.4.64.0608291248410.29142@d.namei> <44F47FB0.5000700@hp.com> <Pine.LNX.4.64.0608291514060.30227@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:18121 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S965277AbWH2UV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:21:56 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0608291514060.30227@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Tue, 29 Aug 2006, Paul Moore wrote:
>>James Morris wrote:
>>>On Tue, 29 Aug 2006, paul.moore@hp.com wrote:
>>>
>>>>+void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
>>>>+				     int family)
>>>>+{
>>>>+        if (family == PF_INET)
>>>
>>>No tab. 
>>
>>I see you already ack'd this patch, should I resubmit with the tab
>>correction or just leave it alone?
> 
> Probably easiest to fix it as it's applied.
> 
>>Example case:
>>
>>1. Configure NetLabel so that packets are labeled with CIPSO
>>2. Ensure SSH is listening for both IPv4 and IPv6 connections and
>>restart the daemon
>>3. Connect to the SSH daemon using IPv4
>>
>>I haven't looked at the sshd code enough in detail to see what it is
>>doing exactly but simply running 'netstat -nl' shows that sshd is
>>listening for connections with an IPv6 socket (at least it is listening
>>on port ':::22').  Once the connection is established the daemon
>>continues to use an IPv6 socket, '::ffff:127.0.0.1:22', whereas the
>>client uses a traditional IPv4 socket.  Sniffing the connection
>>indicates that both directions of network traffic are labeled with the
>>correct CIPSO tags.
> 
> IIRC, the way I originally tested this was to write a simple app.  I 
> wonder if something has changed in the networking code which means we 
> don't need to test for this now.
> 
>>On the outbound side, yes, we only NetLabel sockets which are PF_INET
>>but I didn't think I could set an IPv4 option on a PF_INET6 socket can
>>I?  It just sounds wrong ...
> 
> If it's carrying IPv4 traffic, it may make sense in some cases.
> 

My concern was if the stack would honor the inet_sock->opt field and
after talking to a coworker here it sounds like it would do the right
thing.  I'll work on a patch to label PF_INET6 sockets as well, but like
you said earlier, I don't think it should hold up this patchset.

-- 
paul moore
linux security @ hp
