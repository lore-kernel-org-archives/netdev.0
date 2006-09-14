From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: ipsec policy with netfilter mark value
Date: Thu, 14 Sep 2006 13:04:50 +0200
Message-ID: <BAY103-F408551DB10498F73AE9B53B2290@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s12.bay0.hotmail.com ([65.54.246.212]:4658 "EHLO
	bay0-omc3-s12.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750715AbWINLEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 07:04:52 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everybody.
I would like to know if is it possible to create an ipsec
policy based on the mark value inizialized by netfilter.

This is my problem: I need to route VoIP packets from hosts
connected to the private networks (A & B) to the QoS routers,
without encrypting them. 'Normal' packets are encrypted &
delivered by the ipsec tunnel through the 'Internet router'.

I was thinking to mark them with netfilter (matching on dscp
value) and then create an ipsec policy based on that mark
value.

TIA

                       ___ private network A
                    | /
                    |/
                    |
                    |
              +-----+-----+
              |           |
              |   linux   |
              |   ipsec   |
              |  gateway  |
              |           |
              +--+-----+--+
                 |     |
  +--------+     |     |
  |Internet|     |     |     +------------------+
  |        +-----+     +-----+QoS enabled router|
  | router |                 +------------------+
  +--------+                          ||
     ||                               ||
     ||                               ||
     ||\                              ||
     || \___ipsec tunnel              ||\
     ||    net A <=> net B            || \___QoS WAN network
     ||                               ||     net A <=> net B
     ||                               ||
  +--------+                          ||
  |Internet|                 +------------------+
  |        +-----+     +-----+QoS enabled router|
  | router |     |     |     +------------------+
  +--------+     |     |
                 |     |
              +--+-----+--+
              |           |
              |   linux   |
              |   ipsec   |
              |  gateway  |
              |           |
              +-----+-----+
                    |
                    |
                    |\
                    | \___ private network B


