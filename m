From: Edward Allcutt <edward.allcutt@openmarket.com>
Subject: Re: [PATCH] ipv4: icmp: Fix pMTU handling for rare case
Date: Tue, 1 Jul 2014 09:42:14 +0100 (BST)
Message-ID: <alpine.DEB.2.10.1407010937120.5997@tabini.allcutt.me.uk>
References: <1404141362-21015-1-git-send-email-edward.allcutt@openmarket.com> <20140630.234843.985671994258957329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140630.234843.985671994258957329.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Jul 2014, David Miller wrote:
> From: Edward Allcutt <edward.allcutt@openmarket.com>
> Date: Mon, 30 Jun 2014 16:16:02 +0100
>
>> This is explicitly described as an eventuality that hosts must deal
>> with by the standard (RFC 1191) since older standards specified that
>> those bits must be zero.
> ...
>> One example I have seen is an OpenBSD router terminating IPSec
>> tunnels.
>
> Why doesn't OpenBSD implement RFC 1191?

Why do you think I know? :)

However the standard says that you should interoperate with older 
implementations, and I can't see any downside to doing so.

> I really don't want to allow for zero values.

Why? I have had a look through all the higher level protocols and they 
seem to handle this fine, if they are allowed to see the signal at all. 
Most of them fall back to the minimum packet size, which isn't ideal but 
it's much better than just stalling indefinitely.

If it helps any, I've been running several production machines with this 
patch for just about a year now (mostly running 3.10 stable series).

-- 
Edward Allcutt
