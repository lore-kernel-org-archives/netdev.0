From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Tue, 9 Nov 2010 10:08:21 +0530
Message-ID: <OF529E89EE.84DB37B8-ON652577D6.001665CF-652577D6.00192784@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101026085709.GC23530@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:53103 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab0KIEeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 23:34:50 -0500
In-Reply-To: <20101026085709.GC23530@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 10/26/2010 02:27:09 PM:

> Re: [v3 RFC PATCH 0/4] Implement multiqueue virtio-net
>
> On Mon, Oct 25, 2010 at 09:20:38PM +0530, Krishna Kumar2 wrote:
> > > Krishna Kumar2/India/IBM@IBMIN wrote on 10/20/2010 02:24:52 PM:
> >
> > Any feedback, comments, objections, issues or bugs about the
> > patches? Please let me know if something needs to be done.
> >
> > Some more test results:
> > _____________________________________________________
> >          Host->Guest BW (numtxqs=2)
> > #       BW%     CPU%    RCPU%   SD%     RSD%
> > _____________________________________________________
>
> I think we discussed the need for external to guest testing
> over 10G. For large messages we should not see any change
> but you should be able to get better numbers for small messages
> assuming a MQ NIC card.

I had to make a few changes to qemu (and a minor change in macvtap
driver) to get multiple TXQ support using macvtap working. The NIC
is a ixgbe card.

__________________________________________________________________________
            Org vs New (I/O: 512 bytes, #numtxqs=2, #vhosts=3)
#      BW1     BW2 (%)       SD1    SD2 (%)        RSD1    RSD2 (%)
__________________________________________________________________________
1      14367   13142 (-8.5)  56     62 (10.7)      8        8 (0)
2      3652    3855 (5.5)    37     35 (-5.4)      7        6 (-14.2)
4      12529   12059 (-3.7)  65     77 (18.4)      35       35 (0)
8      13912   14668 (5.4)   288    332 (15.2)     175      184 (5.1)
16     13433   14455 (7.6)   1218   1321 (8.4)     920      943 (2.5)
24     12750   13477 (5.7)   2876   2985 (3.7)     2514     2348 (-6.6)
32     11729   12632 (7.6)   5299   5332 (.6)      4934     4497 (-8.8)
40     11061   11923 (7.7)   8482   8364 (-1.3)    8374     7495 (-10.4)
48     10624   11267 (6.0)   12329  12258 (-.5)    12762    11538 (-9.5)
64     10524   10596 (.6)    21689  22859 (5.3)    23626    22403 (-5.1)
80     9856    10284 (4.3)   35769  36313 (1.5)    39932    36419 (-8.7)
96     9691    10075 (3.9)   52357  52259 (-.1)    58676    53463 (-8.8)
128    9351    9794 (4.7)    114707 94275 (-17.8)  114050   97337 (-14.6)
__________________________________________________________________________
Avg:      BW: (3.3)      SD: (-7.3)      RSD: (-11.0)

__________________________________________________________________________
            Org vs New (I/O: 1K, #numtxqs=8, #vhosts=5)
#      BW1      BW2 (%)       SD1   SD2 (%)        RSD1   RSD2 (%)
__________________________________________________________________________
1      16509    15985 (-3.1)  45    47 (4.4)       7       7 (0)
2      6963     4499 (-35.3)  17    51 (200.0)     7       7 (0)
4      12932    11080 (-14.3) 49    74 (51.0)      35      35 (0)
8      13878    14095 (1.5)   223   292 (30.9)     175     181 (3.4)
16     13440    13698 (1.9)   980   1131 (15.4)    926     942 (1.7)
24     12680    12927 (1.9)   2387  2463 (3.1)     2526    2342 (-7.2)
32     11714    12261 (4.6)   4506  4486 (-.4)     4941    4463 (-9.6)
40     11059    11651 (5.3)   7244  7081 (-2.2)    8349    7437 (-10.9)
48     10580    11095 (4.8)   10811 10500 (-2.8)   12809   11403 (-10.9)
64     10569    10566 (0)     19194 19270 (.3)     23648   21717 (-8.1)
80     9827     10753 (9.4)   31668 29425 (-7.0)   39991   33824 (-15.4)
96     10043    10150 (1.0)   45352 44227 (-2.4)   57766   51131 (-11.4)
128    9360     9979 (6.6)    92058 79198 (-13.9)  114381  92873 (-18.8)
__________________________________________________________________________
Avg:      BW: (-.5)      SD: (-7.5)      RSD: (-14.7)

Is there anything else you would like me to test/change, or shall
I submit the next version (with the above macvtap changes)?

Thanks,

- KK

