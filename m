From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net v2 2/2] ipv6: fix ECMP route replacement
Date: Fri, 15 May 2015 19:41:56 +0200
Message-ID: <20150515174156.GB32190@unicorn.suse.cz>
References: <5554F073.4080501@6wind.com>
 <20150514214907.GA20301@lion>
 <20150515085151.GA32190@unicorn.suse.cz>
 <20150515.121212.20831661856896659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150515.121212.20831661856896659.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 15, 2015 at 12:12:12PM -0400, David Miller wrote:
> From: Michal Kubecek <mkubecek@suse.cz>
> Date: Fri, 15 May 2015 10:51:52 +0200
> 
> > But I still rather feel like replacing all existing matching routes
> > would better reflect what I expect "replace" to do.
> 
> What does IPV4 do?

Apparently there is some problem too as on 4.1-rc3, "ip route replace"
seems to always remove first matching IPv4 route (multipath or not) but
doesn't add the new one unless there was no matching route before
calling the command (then it behaves like "add").

I also tried 3.0 and it replaces first matching route, whether it was
multipath or not and whether the new one is multipath or not. This
behaviour cannot be directly transfered to IPv6 as there are no real
IPv6 multipath routes; instead, the set of all routes under a node with
the same metric satisfying rt6_qualify_for_ecmp() is handled as a
multipath route (so that there can be only one). The semantics I
suggested in my previous mail might be a reasonable approximation.

                                                         Michal Kubecek
