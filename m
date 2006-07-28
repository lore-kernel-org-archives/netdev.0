From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 20:58:25 +0200
Message-ID: <20060728185825.GG14627@postel.suug.ch>
References: <20060717155224.060020000@hp.com> <20060717155822.315389000@hp.com> <20060728112426.GE14627@postel.suug.ch> <44CA504C.6030207@hp.com> <20060728181225.GF14627@postel.suug.ch> <44CA59D8.4090702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:238 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161245AbWG1S6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 14:58:09 -0400
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <44CA59D8.4090702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul Moore <paul.moore@hp.com> 2006-07-28 14:39
> It sounds like you main concern is that I'm not using the netlink
> attribute interfaces, yes?  I looked at using those originally but
> decided not to use them for the following reasons:
> 
>  1. They are listed as "optional" in the documents I read
>  2. They add at least an extra 32 bits to each attribute
>  3. There seems to be plenty of users in net/ipv4 who do not make
>     use of attributes (a *quick* look again reveals none)
>  4. Since I'm reading messages from userspace I can't trust the
>     message contents regardless of it's use of attributes
>  5. Harder to work with in userspace without using a netlink
>     library, which would create an extra dependency for tools which
>     talk to the NetLabel subsystem
> 
> Basically, I saw no requirement to use the netlink attributes and no
> advantage so I didn't.  Is this reasonable, or do you feel the use of
> attributes is a requirement?

Not a requirement but I would encourage it. Almost all netlink
families are using attributes with a few exceptions. We just
used to call them rtattr defined in rtnetlink.h before the new
api was added. There is one huge advantage in using attributes
which is that your protocol is extendable without breaking binary
interfaces.

What I'm refering to primarly are the existing functions to write
netlink and genetlink headers etc.

