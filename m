From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 16:38:57 -0700
Message-ID: <469FF611.6080905@candelatech.com>
References: <930446.33248.qm@web56601.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: andrei radulescu-banu <iubica2@yahoo.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932816AbXGSXjX@vger.kernel.org>
In-Reply-To: <930446.33248.qm@web56601.mail.re3.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

andrei radulescu-banu wrote:
> During debugging, I noticed that dev_queue_xmit() is called twice for tx vlan frames. This results in a frame being passed twice to a packet socket bound to 'any' interface. If the packet socket is bound to a specific interface, though, it will get only one copy of the tx frame, which is good.
> 
> In more detail: suppose we're tx'ing a frame, and the route table lookup yields a vlan outgoing device eth0.2. dev_queue_xmit() is called, which calls dev_queue_xmit_nit() for dev = eth0.2 then dev->hard_start_xmit() for dev = eth0.2. 
> 
> The latter call gets into the vlan layer, which attaches the vlan id 2 (accelerated or not... in my e1000 case accelerated) then calls dev_queue_xmit() again. This time around dev_queue_xmit_nit() is called for dev = eth0, and dev->hard_start_xmit() actually calls the ethernet driver.
> 
> The net result is that dev_queue_xmit_nit() is called twice, once for dev=eth0.2 then for dev=eth0.

Maybe binding to all isn't such a good idea then.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
