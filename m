From: Balint Marton <cus@fazekas.hu>
Subject: RE: [PATCH] get_random_bytes returns the same on every boot
Date: Mon, 26 Jul 2004 21:31:38 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0407262019080.28678@cinke.fazekas.hu>
References: <C0170D0AF1277849A4B4518034F855DD0CFC2F@aiexchange.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eble, Dan" <DanE@aiinet.com>
In-Reply-To: <C0170D0AF1277849A4B4518034F855DD0CFC2F@aiexchange.ai.aiinet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 26 Jul 2004, Eble, Dan wrote:
> If many systems are booting at the same time, is seeding with the system
> time really an appropriate solution?  Shouldn't some system-specific
> value also contribute to the randomization?

Yes, i agree, it would be nicer, if we could also use some 
system-specific stuff for the seeding, but i don't know if there is 
such data during the initialization of the random module. For example, 
we may use the MAC address of a network device, but unless i am mistaken 
the initialization of such network devices take place after the random 
dirver init. 

By the way, i made a little test with 40 computers. They were totally 
equvivalent by hardware, and all of them had a synchronized system 
clock. I turned them on by Wake On LAN exactly at the same time. All of 
them used the kernel level ip autoconfig, all of them got their right IP 
address, and i didn't even find a line of DHCPNAK in the dhcpd logfile.

Conclusion: Although using some system-specific data and the clock would 
be nicer, the system time alone also does the right thing dependably.

bye,
Cus
