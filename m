From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: TGe (QoS in wireless)
Date: Fri, 11 Jun 2004 14:02:16 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406111402.23898.vkondra@mail.ru>
References: <200406090936.16943.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200406090936.16943.vkondra@mail.ru>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Wednesday 09 June 2004 09:36, Vladimir Kondratiev wrote:

News:

latest development in this group goes into direction, when "ACM" (Admission 
Control Mandatory) will be used for 2 high priority EDCA access categories 
(video and voice).
This means, if STA want to Tx at high priority, it should request bandwidth 
from AP by creating TSPEC.
If STA violete its spec, its traffic may be dropped by AP, or STA may be 
disconnected. Violations include:
- - STA Tx packet at high priority without admission,
- - STA exceed TSPEC's bandwidth

This mean, unless we implement TGe in wireless, Linux STA will get lowest 
priority for its traffic.

Vladimir.

> I will give short overview for TGe.
>
> TGe is working group in IEEE, who is working on QoS for 802.11 wireless
> network. This work is close to completion, final draft will be voted and
> become standard shortly.
>
> Next generation of wireless cards will support TGe.
>
> Now, to the business.
>
> Single radio channel used.
>
> There are 2 access disciplines:
>
> - EDCA, which is CSCA, or contention based. 4 AC (access categories) exist,
> they differ by channel access parameters. Parameters include backoff,
> contention window and TXOP (more on this later). Parameters are set by AP
> and may be changed during operation.
>
> - HCCA, which is contention free access. AP (access point) gives TXOP
> directly to each STA, deciding who will speak.
>
> TXOP stands for transmitt opportunity. When each AC gets access to the
> channel, it is allowed to do burst (without backoff) for TXOP period, which
> is several ms.
>
> Traffic classified into 16 categories, or TID. Each packet get its TID.
> TID 0-7 get mapped statically to 4 AC, roughly it corresponds to TOS bits.
>
> TID 8-15 mapped to TSPECs. TSPEC is traffic specification, which consist of
> bandwidth specification (throughput, delay etc. - see RSVP for example) and
> TCLAS - classifiers passed to AP side to classify packets.
>
> TSPEC may be for HCCA or EDCA access. In case of HCCA, it get simple
> periodic schedule, set by AP. AP will poll STA accordingly to this
> schedule, and Tx to STA accordingly to schedule. In case of EDCA, it is
> just bandwidth allocation control.
>
> Admission. AP may enforce admission control for some (actually, 2 high
> prio) AC, prohibiting its normal operation and requiring TSPEC
> establishment in order to use these categories.
>
> I did not touched B-ACK (block ack), local broadcast, and DLP (direct link
> protocol) that deals nothing with QoS.
>
> ----------below is my interpretation-----------
> This leads to the following channel model :
> - single Rx channel
> - 4 FIFO/DMA rings, one per AC.
> - 1 to 8 FIFO/DMA rings for TSPEC traffic.
>  In-NIC scheduler decides which FIFO get to the air. Time for decision is
> about 10 us, thus it can't be done on host.
> Decision is the following:
> - poll from AP -> TSPEC
> - channel is clear, random backoff expired -> AC
>
> Vladimir.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAyZE/qxdj7mhC6o0RAvhAAJ97+J8cMeW1ieFTU4WOMO0m3PlonACbBD2X
Xf6n+chLDYWLJKuTWc0CTug=
=3VtG
-----END PGP SIGNATURE-----
