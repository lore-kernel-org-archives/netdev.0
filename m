From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Fri, 15 Sep 2017 16:26:17 +0200
Message-ID: <20170915142617.GA2060@nanopsycho.orion>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
 <20170907193434.GA11006@kroah.com>
 <87h8wdb8bj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAJGZr0KdOPW5_V3kvWutwTY=BJhfd-=yRDPnvbDBOCuMYWj9OQ@mail.gmail.com>
 <CAKgT0Uf8--Yh9tfkTrh9_dfEYMX5jR6j4unxwxM+WD6E4jk9pA@mail.gmail.com>
 <20170914210132.GC3084@lunn.ch>
 <20170915055107.GA1927@nanopsycho.orion>
 <20170915140839.GD3084@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, kernel@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:47308 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdIOO0V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 10:26:21 -0400
Received: by mail-wr0-f175.google.com with SMTP id k20so1982675wre.4
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 07:26:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170915140839.GD3084@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 15, 2017 at 04:08:39PM CEST, andrew@lunn.ch wrote:
>> Could you put together your requirements so we can work it out to extend
>> devlink to support them?
>
>As i've said multiple times, generic two dimensional tables. Examples
>could look like:
>
>Stats                 cpu     lan0   lan1   lan2   lan3   lan4    dsa
>---------------------------------------------------------------------
>tx_packets:              2       0      0      0      0      0      0
>tx_bytes:             1180    6666      0      0      0      0      0
>rx_packets:              0       0      0      0      0      0      0
>rx_bytes:                0    1180      0      0      0      0      0
>in_good_octets:       6666    1188      0      0      0      0      0
>in_bad_octets:           0       0      0      0      0      0      0
>in_unicast:              0       0      0      0      0      0      0
>in_broadcasts:           0       0      0      0      0      0      0
>in_multicasts:          89       0      0      0      0      0      0
>in_pause:                0       0      0      0      0      0      0
>in_undersize:            0       0      0      0      0      0      0
>in_fragments:            0       0      0      0      0      0      0
>in_oversize:             0       0      0      0      0      0      0
>in_jabber:               0       0      0      0      0      0      0
>in_rx_error:             0       0      0      0      0      0      0
>in_fcs_error:            0       0      0      0      0      0      0
>out_octets:           1188    6666      0      0      0      0      0
>out_unicast:             0       0      0      0      0      0      0
>out_broadcasts:          2       2      0      0      0      0      0
>out_multicasts:          0      89      0      0      0      0      0
>out_pause:               0       0      0      0      0      0      0
>excessive:               0       0      0      0      0      0      0
>collisions:              0       0      0      0      0      0      0
>deferred:                0       0      0      0      0      0      0
>single:                  0       0      0      0      0      0      0
>multiple:                0       0      0      0      0      0      0
>out_fcs_error:           0       0      0      0      0      0      0
>late:                    0       0      0      0      0      0      0
>hist_64bytes:            0       0      0      0      0      0      0
>hist_65_127bytes:        0       0      0      0      0      0      0
>hist_128_255bytes:       0       0      0      0      0      0      0
>hist_256_511bytes:       0       0      0      0      0      0      0
>hist_512_1023bytes:      0       0      0      0      0      0      0
>hist_1024_max_bytes:     0       0      0      0      0      0      0
>sw_in_discards:          0       0      0      0      0      0      0
>sw_in_filtered:          0       0      0      0      0      0      0
>sw_out_filtered:        89      89      0      0      0      0      0

I believe we discussed this already. You can have devlink_port instance
for each port, then you just have stats-per-devlink_port. Looks quite
easy to implement actually.

Would be mistake to have this as just 2 dim array.


>
>
>   Reg  cpu     lan0    lan1    lan2    lan3    lan4    lan5  global0 global1
>-----------------------------------------------------------------------------
>    00: 4e07	4d04	4d04	4d04	4d04	4d04	4d04     0000   00000
>    01: 403e	003d	003d	003d	003d	003d	003d     0000   00000
>    02: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    03: 3521	3521	3521	3521	3521	3521	3521     0000   00000
>    04: 0533	373f	373f	373f	373f	373f	373f     0000   00000
>    05: 8000	0000	0000	0000	0000	0000	0000     0000   00000
>    06: 005f	003f	003f	003f	003f	003f	003f     0000   00000
>    07: 002a	002a	002a	002a	002a	002a	002a     0000   00000
>    08: 2080	2080	2080	2080	2080	2080	2080     0000   00000
>    09: 0001	0001	0001	0001	0001	0001	0001     0000   00000
>    0a: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    0b: 0020	0000	0000	0000	0000	0000	0000     0000   00000
>    0c: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    0d: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    0e: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    0f: 9100	dada	dada	dada	dada	dada	dada     0000   00000
>    10: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    11: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    12: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    13: 0000	00d8	00d8	00d8	00d8	00d8	00d8     0000   00000
>    14: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    15: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    16: 0022	0000	0000	0000	0000	0000	0000     0000   00000
>    17: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    18: 3210	2210	2210	2210	2210	2210	2210     0000   00000
>    19: 7654	7654	7654	7654	7654	7654	7654     0000   00000
>    1a: 0000	0000	0000	0000	0000	0000	0000     0000   00000
>    1b: 8000	8000	8000	8000	8000	8000	8000     0000   00000
>    1c: 0000    0000    0000    0000    0000    0000    0000     0000   00000
>    1d: 0000    0000    0000    0000    0000    0000    0000     0000   00000
>    1e: 0000    0000    0000    0000    0000    0000    0000     0000   00000
>    1f: 0000    0000    0000    0000    0000    0000    0000     0000   00000
>

Is this a reg dump per-port? Also, with per-port devlink_port instance,
you can have reg array for each. How the values can change? Is this
change result of driver<->hw communication? If yes, you might consider
using devlink hwmsg trace to expose the communication to userspace.


>So a table would have an optional header row. Then a number of data
>rows. The number of columns is the same for each row. The number of
>columns is determined at run time, but is known at the beginning of
>enumerating the table. The number of data rows is not known until the
>last one is enumerated.

I would rather focus on what exactly you need to expose to userspace,
then we can figure out how to do it. Generic multipurpose arrays should
be considered as last-resort solution in my opinion.


>
>Each cell in the row is typed. Can be a string, bool, u8, u16, u32, u64,
>ifindex, MAC address, IP address, devlink port, ....
>
>Each cell in a row can have a different type. The types of the header
>row cells can be different to the types of the data cells. All data
>rows have the same type information. So you can enumerate the types
>once, and use them for the whole table.
>
>The userspace tool should make its best effort to print the table,
>using the type info. It might need hits from the command line, like -x
>to print in hex not decimal. The second example shows this. Registers
>make more sense in hex, where as statistics make more sense in
>decimal. But let the user choose, so keeping the kAPI simple.  This is
>intended as a debug tool. The output does not need to be highly
>polished. But it needs to be a lot more readable than the current
>dpipe output which prints a table as a list, not a table.
>
>The tables can be per port, or per switch. Remember that DSA allows a
>cluster of switches within one DSA instance.
>
>Vivien, Florian, did i miss anything?
>
>	 Andrew
