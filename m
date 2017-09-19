From: Marco Berizzi <pupilla@libero.it>
Subject: software interrupts close to 100 with 9000 tc filter entries
Date: Tue, 19 Sep 2017 15:28:58 +0200 (CEST)
Message-ID: <1627070802.486441.1505827738125@mail.libero.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-33-i5.italiaonline.it ([212.48.25.234]:55520 "EHLO
        libero.it" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750822AbdISN3A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 09:29:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks,

I'm running linux 4.12.10 x86_64 on a Slackware 14.2 64bit
as a simple 4 NIC router. Network throughput processed by
this machine is less than 200Mbit/s
The cpu model is Intel(R) Xeon(R) CPU 5160  @ 3.00GHz with
2GB ram.

I need to blacklist about 9000 single ip addresses.
This is the relevant script to blacklist these ip addresses:

tc qdisc add dev eth0 ingress
tc qdisc add dev eth1 ingress

while read -r line
do
    tc filter add dev eth0 parent ffff: protocol ip prio 50 u32 match ip src $line action drop
    tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match ip src $line action drop
done < blacklisted_ip_addresses

After loading these ip addresses, the si (software interrupts)
number shown by top is always close to 100
If I delete the ingress qdisc on both the device, the si
fall down to less than 5

Running the same script with 'only' 700 ip addresses is
flawless.

Kindly I would like to ask if am I doing anything in
a wrong way or if the hardware is too old for this kind
of setup.

I have selected the tc filter setup instead of netfilter
one, because I was reading this from iproute2/doc/actions:

A side effect is that we can now get stateless firewalling to work with tc..
Essentially this is now an alternative to iptables.
I wont go into details of my dislike for iptables at times, but.
scalability is one of the main issues; however, if you need stateful
classification - use netfilter (for now).

Any response are welcome
TIA

Marco
