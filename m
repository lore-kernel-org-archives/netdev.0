From: Leandro Lucarella <luca@llucax.com.ar>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Wed, 20 Oct 2010 15:24:11 -0300
Message-ID: <20101020182411.GO8781@llucax.com.ar>
References: <4CBCD429.8090306@windriver.com>
 <20101018234547.GA5703@hmsreliant.think-freely.org>
 <20101019021657.GZ8781@llucax.com.ar>
 <20101019.011649.71113115.davem@davemloft.net>
 <20101019110452.GA14410@hmsreliant.think-freely.org>
 <20101019131936.GB8781@llucax.com.ar>
 <20101019201841.GC14410@hmsreliant.think-freely.org>
 <20101020172018.GN8781@llucax.com.ar>
 <0434463FDA60A94FA978ACA44617682DEE84668199@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0434463FDA60A94FA978ACA44617682DEE84668199@EUSAACMS0702.eamcs.ericsson.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Maloy, el 20 de octubre a las 13:57 me escribiste:
> > Another option is to change the TIPC 2.0 specification to use 
> > the old format (use HBO in subscriptions and keep 
> > TIPC_SUB_SERVICE as a separate flag with value 2) and forget 
> > about all this. After all, I can't see what advantages gives 
> > having to change the BO for internal messages between the 
> > applications and the stack.
> 
> I agree with this. I have no problems with changing the draft 
> (which as Leandro already noted is "work-in-progress") to specify that 
> both HBO and NBO are permitted over the wire, and that it is the
> topology server's task to keep track of which one is used.

Just to try to understand better how things works, or are supposed to
work: do the subscription and event messages (and I mean the struct
tipc_subscr and tipc_event published in tipc.h) really go over the wire
or are only used to communicate the stack to the application inside
a node?

I think this is a crucial matter, since it defines if the changes cross
kernel/userspace boundaries only or it also crosses the kernel/network
boundaries.

> Remember, permitting both is a superset of the current one (NBO only)
> so it is fully backwards compatible. We break absolutly nothing by
> permitting this.

I think if they really go through the wire, it should be in NBO, and if
tipc_subscr and tipc_event are used only internally, we can still fix
the userspace messages when sending them through the wire.

In any case, I agree that the patches should be reverted and a solution
should be planned with more time and consensus.

Thanks.

-- 
Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
----------------------------------------------------------------------
GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
----------------------------------------------------------------------
The world's best known word is "okay"
The second most well-known word is "Coca-Cola"
