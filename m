From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.6.23-rc8: cannot make netconsole work
Date: Fri, 28 Sep 2007 10:32:53 -0500
Message-ID: <20070928153253.GV19691@waste.org>
References: <200709281327.59317.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrey Borzenkov <arvidjaar@mail.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759928AbXI1PdW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200709281327.59317.arvidjaar@mail.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2007 at 01:27:55PM +0400, Andrey Borzenkov wrote:
> I finally decided to try netconsole in attempt to get some more information 
> why my system does not resume (but that is different story). But I cannot 
> make it work - it does load but I see no traffic flowing ever. This is 
> notebook with e100 driver and it works just fine for normal traffic. 
> netconsole is currently compiled as module, loading it I get:
> 
> sudo modprobe netconsole netconsole=@/eth0,@/ 
> 
> [ 2395.838094] netconsole: local port 6665
> [ 2395.838126] netconsole: interface eth0
> [ 2395.838132] netconsole: remote port 6666
> [ 2395.838140] netconsole: remote IP 0.0.0.0
> [ 2395.838150] netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
> [ 2395.838175] netconsole: local IP 192.168.1.8
> [ 2395.843798] console [netcon0] enabled
> [ 2395.844722] netconsole: network logging started
> 
> but I cannot see any packet flowing via eth0 not can I catch anything on 
> remote side using netcat. This does not work when I add explicitly source and 
> target addresses either:
> 
> pts/0}% sudo modprobe netconsole netconsole=@192.168.1.8/eth0,@192.168.1.5/
> {pts/0}% dmesg | tail
> [ 2427.128947] device eth0 left promiscuous mode
> [ 2427.129005] audit(1190970818.972:5): dev=eth0 prom=0 old_prom=256 
> auid=4294967295
> [ 2541.831721] netconsole: local port 6665
> [ 2541.831756] netconsole: local IP 192.168.1.8
> [ 2541.831763] netconsole: interface eth0
> [ 2541.831769] netconsole: remote port 6666
> [ 2541.831776] netconsole: remote IP 192.168.1.5
> [ 2541.831787] netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
> [ 2541.838832] console [netcon0] enabled
> [ 2541.839964] netconsole: network logging started

What is your console log level set to? If the messages don't come out
on the local console, they won't get sent out the network either.
Fedora at least defaults to hiding most messages. Adding 'debug' to
your kernel command line will change that.

-- 
Mathematics is the supreme nostalgia of our time.
