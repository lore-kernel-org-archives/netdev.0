From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 0/6] Allow bridge to function in
 non-promisc mode
Date: Fri, 19 Apr 2013 13:58:00 -0700
Message-ID: <20130419135800.221bea5a@nehalam.linuxnetplumber.net>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Apr 2013 16:52:44 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> This series is an almost complete rework of the prior attempt
> to make the bridge function in non-promisc mode.  In this series
> the "promiscuity" of an interface is dynamically determined and
> the interface may transition from/to promiscuous mode based on
> bridge configuration.
> 
> The series keeps an idea of an "uplink" port.  That is still user
> designated.
> The series also adds a concept of "dynamic" bridge port.  This is
> the default state of the port and means that the user has not
> specified any static FDBs for that port.
> Once a user has added a static FDB entry to port and also specified
> an "uplink" flag for that FDB, the mac address from that FDB is
> added to the bridge hw address list and synched down to uplinks.
> "Uplinks" are always considered dynamic ports even if a static entry
> has been added for them.
> Promiscuity is determined by the number of dynamic ports.  If there
> are no dynamic ports (i.e all ports have static FDBs set), then we
> know all the neighbors and can switch promisc off on all of the ports.
> If we have only 1 dynamic port and its an uplink, we can synch all
> static hw addresses to this port and mark it non-promisc.
> If we have more then 1 dynamic port, then all ports have to be
> promiscuouse.
> This is the algorith that Michael Tsirkin proposed earlier.
> 

It seems that this bridge with uplink port is just a flavor of macvlan.
The only argument you made for not using macvlan is that user scripts
are expecting bridge API for setup.  Which sounds a lot like the original
OVS fake-bridge which was dropped when merged upstream.
