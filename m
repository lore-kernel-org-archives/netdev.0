From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: [PATCH 0/3] macvlan: support for guest vm direct rx/tx
Date: Fri, 13 Nov 2009 16:05:35 -0700
Message-ID: <4AFD83CF020000C700079883@soto.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net
To: <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-11-13 at 13:27 -0800, Stephen Hemminger wrote:
> On Fri, 13 Nov 2009 14:55:06 -0500
> Patrick Mullaney <pmullaney@novell.com> wrote:
> 
> > These patches allow other modules to override the receive
> > path of a macvlan. This is being done to support guest
> > VMs operating directly over a macvlan. Routines to allow
> > creation and deletion of macvlans from in-kernel modules
> > were also exposed/added.
> 
> Which guest VM, how will it use it? The kernel is not in the business
> of providing infrastructure for out of tree patches.

Actually, any guest vm or container. macvtap was the first to suggest
a patch like this to provide this functionality. This infrastructure
is generic enough to allow others to use it. My interest is in
supporting kvm guests via vbus drivers which are being integrated
in the alacrityvm tree.

> 
> Also, macvlan should really being calling netif_receive_skb()
> not going through another queue/softirq cycle.
I understand but you are talking about the current behavior of
macvlans - my goal wasn't to change the current behavior
of macvlans, as I didn't want to disturb what the original author
intended, just provide the ability to override the rx path and
provide for management of macvlans from other kernel modules(not
just via rtnl).
