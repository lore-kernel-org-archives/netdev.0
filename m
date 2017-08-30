From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: add generic debugfs interface
Date: Wed, 30 Aug 2017 09:43:04 +0200
Message-ID: <20170830074304.GB1903@nanopsycho>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828195332.GB1950@nanopsycho.orion>
 <20170828200834.GA1870@lunn.ch>
 <20170829062523.GA1977@nanopsycho.orion>
 <20170829125004.GB22093@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829125004.GB22093@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Aug 29, 2017 at 02:50:04PM CEST, andrew@lunn.ch wrote:
>On Tue, Aug 29, 2017 at 08:25:23AM +0200, Jiri Pirko wrote:
>> Mon, Aug 28, 2017 at 10:08:34PM CEST, andrew@lunn.ch wrote:
>> >> I see this overlaps a lot with DPIPE. Why won't you use that to expose
>> >> your hw state?
>> >
>> >We took a look at dpipe and i talked to you about using it for this
>> >sort of thing at netconf/netdev. But dpipe has issues displaying the
>> >sort of information we have. I never figured out how to do two
>> >dimensional tables. The output of the dpipe command is pretty
>> >unreadable. A lot of the information being dumped here is not about
>> >the data pipe, etc.
>> 
>> So improve it. No problem. Also, we extend it to support what you neede.
>
>Will i did try to do this back in March. And i failed.
>
>Lets start with stats. Vivien gives an example on the cover letter:
>
>    # pr -mt switch0/port{5,6}/stats
>    in_good_octets      : 0             in_good_octets      : 13824
>    in_bad_octets       : 0             in_bad_octets       : 0
>    in_unicast          : 0             in_unicast          : 0
>    in_broadcasts       : 0             in_broadcasts       : 216
>    in_multicasts       : 0             in_multicasts       : 0
>    in_pause            : 0             in_pause            : 0
>    in_undersize        : 0             in_undersize        : 0
>
>This is what i tried to implement using dpipe. It is a simple two
>dimensional table. First column is a string, second a u64. In debugfs
>we have such a table per port. That fits with the hierarchy that each
>port is a directory in debugfs. But it could also be implemented as
>one table with N+1 columns, for N switch ports.

Andrew, we talked about this in Montreal. What I suggested then was for
port stats to introduce devlink port statistics. Then you can have stats
for all sorts of ports that don't have netlink instance associated,
including cpu port. It aligns.


>
>How about you, or one of your team, implement that. It should be able
>to use the dsa_loop driver, which is a simple dummy switch. But it
>does have statistics counters for all ports. Florian or I can help you
>get it running if needed.
>
>This branch contains some of the basic plumbing code from my previous
>attempt:
>
>https://github.com/lunn/linux.git v4.11-rc4-net-next-dpipe
>
>	 Andrew
>
