From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 26 Jul 2016 11:56:37 +0200
Message-ID: <20160726095637.GC8749@unicorn.suse.cz>
References: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.173701.1282720667210726281.davem@davemloft.net>
 <CO2PR03MB2182D011056AA151CCEF4EFFBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.213822.1745865660912873332.davem@davemloft.net>
 <CO2PR03MB218254B70CBD052069CDEB4FBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"dave.scott@docker.com" <dave.scott@docker.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CO2PR03MB218232A5C9AE5DBD2AB0374ABF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 26, 2016 at 07:09:41AM +0000, Dexuan Cui wrote:
> If you meant https://lkml.org/lkml/2016/7/13/382, I don't think Michal
> Kubecek was suggesting I build my code using the existing AF_VSOCK
> code(?)  I think he was only asking me to clarify the way I used to write
> the text to explain why I can't fit my code into the existing AF_VSOCK
> code. BTW, AF_VSOCK is not on S390, I think.

Actually, I believe building on top of existing AF_VSOCK should be the
first thought and only if this way shows unfeasible, one should consider
a completely new implementation from scratch. After all, when VMware was
upstreaming vsock, IIRC they had to work hard on making it a generic
solution rather than a one purpose tool tailored for their specific use
case.

What I wanted to say in that mail was that I didn't find the reasoning
very convincing. The only point that wasn't like "AF_VSOCK has many
features we don't need" was the incompatible addressing scheme. The
cover letter text didn't convince me it was given as much thought as it
deserved. I felt - and it still feel - that the option of building on
top of vsock wasn't considered seriously enough.

I must also admit I'm a bit confused by your response to the issue of
socket lookup performance. I always thought the main reason to use
special hypervisor sockets instead of TCP/IP over virtual network
devices was efficiency (to avoid the overhead of network protocol
processing). The fact that traversing a linear linked list under
a global mutex for each socket lookup is not an issue as opening
a connection is going to be slow anyway surprised me therefore. But
maybe it's fine as the typical use case is going to be small number of
long running connections and traffic performance is going to make for
the connection latency. Or there are other advantages, I don't know.
But if that is the case, it would IMHO deserve to be explained.

                                                       Michal Kubecek
