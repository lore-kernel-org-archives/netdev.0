From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 8/8] net: Implement socketat.
Date: Mon, 04 Oct 2010 12:07:58 -0700
Message-ID: <m1bp797p4h.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	<m1bp7oq1u8.fsf@fess.ebiederm.org> <4C9B162E.7040201@parallels.com>
	<1285240797.5036.5.camel@bigi> <4C9B3B06.900@parallels.com>
	<1285242055.5036.9.camel@bigi> <4C9B3F9C.8080506@parallels.com>
	<4CA7A07C.5030504@free.fr> <1286113441.3812.229.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1286113441.3812.229.camel@bigi> (jamal's message of "Sun, 03 Oct
	2010 09:44:01 -0400")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

> One thing still confuses me...
> The app control point is in namespace0. I still want to be able to
> "boot" namespaces first and maybe a few seconds later do a socketat()...
> and create devices, tcp sockets etc. I suspect create_ns(namespace-name)
> would involve:
>      * open /proc/self/ns/net (namespace-name)
>      * unshare the netns
> Is this correct?

Almost.

create should be:
        * verify namespace-name is not already in use
        * mkdir -p /var/run/netns/<namespace-name>
	* unshare the netns
        * mount --bind /proc/self/ns/net /var/run/netns/<namespace-name>

Are you talking about an replacing something that used to use the linux
vrf patches that are floating around?

Eric
