From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [6/9] ieee80211: ethernet independency
Date: Fri, 3 Jun 2005 22:45:09 -0700
Message-ID: <20050604054509.GB8130@jm.kir.nu>
References: <20050603182625.64d33be3@griffin.suse.cz> <20050603183418.58c47b0c@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>,
        Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050603183418.58c47b0c@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2005 at 06:34:18PM +0200, Jiri Benc wrote:

> Makes the 802.11 layer independent of ethernet. (The previous implementation
> had the ethernet headers built by the ethernet layer and then parsed them and
> rebuilt them into 802.11 headers.)

Many (most?) parts of this change seems to be only for client (managed
and ad-hoc) modes. Has anyone had chance to go through what would be
needed for AP (master mode) and WDS links? What about extra bytes added
for QoS information (IEEE 802.11e/WMM)? Are there places here that will
not handle variable length header nicely?

I haven't yet looked into details, but could someone explain what a user
space program needs to do when receiving or sending packets with packet
socket from a 802.11 netdev (e.g., ethertype=EAPOL)? Let's say in the
"worst case" scenario: QoS enabled and pairwise keys configured and
4-address WDS link (i.e., 32-byte IEEE 802.11 header).

Will the user space program need to parse (and generate) the IEEE 802.11
header, including the knowledge of four addresses and QoS data, and SNAP
header? Packet socket with SOCK_DGRAM could otherwise be one way of
doing this, but sockaddr_ll does not have places for many parameters..

Many of these questions are not really specifically related to this
patch, but I haven't seen a good answer to these open areas (well, at
least to me) so far.

-- 
Jouni Malinen                                            PGP id EFC895FA
