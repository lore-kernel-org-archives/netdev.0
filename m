From: "Alaa Dalghan" <alaadalghan@hotmail.com>
Subject: Modifying Cryptography Code
Date: Tue, 06 Sep 2005 13:56:56 +0000
Message-ID: <BAY106-F336464E0C97EA44289AA87ABA70@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-security-module@mail.wirex.com, linux-crypto@nl.linux.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everyone,
I need to modify some CRYPTOGRAPHY code in Linux Kernel to get a specific 
VPN behavior, but I don't know where to start.

The situation is the following:

I have a VPN gateway (Linux kernel 2.6.10 with Openswan 2.3.1 installed). I 
have only installed the user land tools from openswan package in order to 
use the native ipsec stack in the kernel.
I have 30 laptops equipped with Windows XP configured to launch secure 
tunnels towards the VPN gateway (so I have 30 tunnels). The laptops can 
communicate securely VIA the gateway and everything works fine but..

the problem is the following:

Each packet sent from a given client to the other get processed 4 times 
(encryption at the sender, decryption at the gateway, encryption at the 
gateway, decryption at the receiver). This is the normal behavior but it 
imposes too much processing overhead on the linux VPN gateway. The required 
behavior is that the VPN gateway just RELAYS encrypted data (ESP envelopes) 
without decrypting them. This is impossible in the current ipsec 
implementation since"the end of a tunnel HAS ALWAYS to be decrypted".

Note that this required behavior can be achieved by launching a tunnel from 
each client to every other client making the VPN gateway 
transparent..BUT..this would mean 900 tunnels!! instead of 30, so it is not 
the answer.

What I am looking for is the portion of the C code in the kernel where the 
Decryption function is called to decrypt a received packet. When I find this 
statement, maybe i can make it conditionnal such as:  If the destination is 
me then Decrypt  else DO NOT!

I hope that someone can help me with finding this portion of the code and 
modify it. By the way I searched in the kernel file "esp4.c" but can't seem 
to find what I want.




           
----------------------------------------------------------WinXP(1)
          |
Openswan 
box------------------------------------------------------------WinXP(2)
          |
           
----------------------------------------------------------WinXP(3)
          |
          |
          |
          |
           
---------------------------------------------------------WinXP(30)

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today - it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/

