From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: TGe overview #1
Date: Sat, 17 Jul 2004 00:15:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407170015.59373.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

I promised to do overview for TGe. Now I am starting to deliver on promise.

I did it once already, but now I will try to be more specific and cover almost 
all MAC aspects. I will only briefly mention PHY details.

TGe is working group in IEEE, who is working on QoS for 802.11 wireless 
network. This work is close to completion, final draft will be voted and 
become standard shortly.

To explain how QoS implemented for 802.11, some basics need to be understood. 
Sorry for long introduction.

Briefly about classic 802.11.

There are 2 modes of operation: IBSS, where there is no special station; and 
BSS, where there is one access point (AP), which coordinates activity for all 
stations in the BSS. Usually, AP is also bridge to the wired network.

We will focus on BSS, where AP coordinates everyone's activity, as this is 
main mode of operation. In BSS, each STA send frames only to AP, which 
re-route it to proper destination.

802.11 is carrier sense collision avoidance system. For collision avoidance, 
all stations use carrier sense mechanism. To be able to transmit, STA should 
sense clear channel for some time. This time composed of some fixed interval 
and random backoff.

There are 3 important time intervals - 
- - SIFS (short inter-frame space);
- - PIFS (point coordinator function inter-frame space), which is 2 SIFS;
- - DIFS (distributed coordinator function inter-frame space), which is 3 SIFS

Typical value for SIFS is 16us for .11a

These intervals are used in:
SIFS is interval between frames in control frame exchange (later about frame 
types).
PIFS is interval used by PCF (point coordinator function) to access media. AP 
uses it to gain access to the media when it acts as point coordinator (almost 
unused, will not talk about it) and in some other cases, will describe it 
later.
DIFS used for all stations to gain access to the medium, after DIFS, they 
start to count down random backoff counter. Backoff is number of SIFS.

PCF (point coordinator function) is dictate of AP. It decides who will speak 
next and polls next STA giving it right to transmit.

DCF is equal competition for the channel. 
There is parameters:
- - CWmin, CWmax (contention window min and max). Each STA, when it decides it 
want to Tx, generates random number up to CW. After DIFS, it start counting 
down from this number each SIFS. If it goes to 0, STA starts Tx. If it senses 
energy in the channel, it stops counting, and continue next time when channel 
is clear for DIFS. First, CW=CWmin. If collision occurs, STA doubles its CW, 
and do so up to CWmax. Collision detected by not having ACK(see below).

Frame types:
- - data frames, to carry data.
- - management frames, to maintain MAC state.
- - control frames, to do low level sequences. Control frames used to 
acknowledge data/management frame (ACK); to implement RTS/CTS protection and 
for some other jobs.

Frame exchange consist of frame+ACK, or RTS+CTS+frame+ACK.

Now, TGE.

It introduces TXOP, transmit opportunity. Idea is to lower overhead of backoff 
window. Implementation: when STA wins channel access, it may use it for some 
time called TXOP. During this period, STA can start next frame exchange SIFS 
after previous one. TXOP=0 means one frame may be transmitted.

To obtain TXOP, different interval, AIFS, introduced instead of DIFS, 
AIFS=DIFS+SIFS*AIFSN, where AIFSN is parameter.

In EDCA (enhanced distributed channel access) mode, 4 access categories used, 
which differs by channel access parameters: CWmin, CWmax, AIFSN, TXOP. These 
4 categories acts as independent channel access functions, independently 
competing for the channel. All parameters dictated by AP. This mechanism
used to implement diffserv style QoS.

To be continued...
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA+EWOqxdj7mhC6o0RApUVAKCX8KSBvk7QeQZffS9E0xFLiaf/TwCgga06
7aclJYLLY1YnX7k2MIgdA7Y=
=ruw3
-----END PGP SIGNATURE-----
