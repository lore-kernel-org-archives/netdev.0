From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Mon, 9 Jan 2017 22:23:45 +0100
Message-ID: <20170109212345.GA5513@otheros>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
 <1483706872.4089.8.camel@sipsolutions.net>
 <8836daaa-9638-4502-d079-fd428595f822@nbd.name>
 <1483710841.12677.1.camel@sipsolutions.net>
 <22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
 <20170107145516.GE3134@otheros>
 <1483949336.17582.3.camel@sipsolutions.net>
 <6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Felix Fietkau <nbd@nbd.name>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: "M. Braun" <michael-dev@fami-braun.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 09, 2017 at 12:44:19PM +0100, M. Braun wrote:
> Am 09.01.2017 um 09:08 schrieb Johannes Berg:
> > Does it make sense to implement the two in separate layers though?
> > 
> > Clearly, this part needs to be implemented in the bridge layer due to
> > the snooping knowledge, but the code is very similar to what mac80211
> > has now.
> 
> Does the bridge always know about all stations connected?

The bridge does not always know about all stations, especially the
silent ones like in your DVB-T example.

However, concerning IP multicast, there is IGMP/MLD. So the bridge
does know about all stations which are interested in a specific IP
multicast stream.

(As long as there is a querier on the link, which periodically
queriers for IGMP/MLD reports from any listener. If there is no
querier then the bridge multicast snooping, including the bridge
multicast-to-unicast will fall back to flooding)


So if your television example uses IP multicast properly, it is
completely doable with the bridge multicast-to-unicast, thanks to
IGMP/MLD.
