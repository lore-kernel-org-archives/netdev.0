From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 14:39:20 -0400
Message-ID: <44CA59D8.4090702@hp.com>
References: <20060717155224.060020000@hp.com> <20060717155822.315389000@hp.com> <20060728112426.GE14627@postel.suug.ch> <44CA504C.6030207@hp.com> <20060728181225.GF14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:52380 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1161228AbWG1SjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 14:39:22 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060728181225.GF14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Paul Moore <paul.moore@hp.com> 2006-07-28 13:58
> 
>>I'm  a little confused by your comment, could you be a bit more
>>specific?  Are you basing your comment strictly on the text above?  If
>>so, the problem may be my poor excuse for documentation rather then my
>>poor excuse for implementation :)
>>
>>I am using the generic netlink interface, in what I believe to be a
>>"correct" fashion - please correct me if I'm wrong.
> 
> The netlink bits are spread around all patches so I just quoted
> on this comment. By adding functions like netlbl_align(),
> netlbl_put_u8(), netlbl_put_hdr() writing a netlink header
> etc. you are just duplicating the already existing interfaces
> found in net/netlink.h and net/genetlink.h.

Thanks for the clarification, I think I understand your point a bit
better now.

It sounds like you main concern is that I'm not using the netlink
attribute interfaces, yes?  I looked at using those originally but
decided not to use them for the following reasons:

 1. They are listed as "optional" in the documents I read
 2. They add at least an extra 32 bits to each attribute
 3. There seems to be plenty of users in net/ipv4 who do not make
    use of attributes (a *quick* look again reveals none)
 4. Since I'm reading messages from userspace I can't trust the
    message contents regardless of it's use of attributes
 5. Harder to work with in userspace without using a netlink
    library, which would create an extra dependency for tools which
    talk to the NetLabel subsystem

Basically, I saw no requirement to use the netlink attributes and no
advantage so I didn't.  Is this reasonable, or do you feel the use of
attributes is a requirement?

-- 
paul moore
linux security @ hp
