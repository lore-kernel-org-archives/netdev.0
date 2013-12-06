From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data
 in code executed on non-rx_handler path
Date: Fri, 6 Dec 2013 13:10:28 -0800
Message-ID: <20131206131028.41b5b8b1@nehalam.linuxnetplumber.net>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
	<20131206.154321.1673089712073824539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jtluka@redhat.com, jiri@resnulli.us, mst@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, edumazet@google.com,
	laine@redhat.com, zhiguohong@tencent.com
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20131206.154321.1673089712073824539.davem@davemloft.net>
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

On Fri, 06 Dec 2013 15:43:21 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Jiri Pirko <jiri@resnulli.us>
> Date: Thu,  5 Dec 2013 16:27:37 +0100
> 
> > br_stp_rcv() is reached by non-rx_handler path. That means there is no
> > guarantee that dev is bridge port and therefore simple NULL check of
> > ->rx_handler_data is not enough. There is need to check if dev is really
> > bridge port and since only rcu read lock is held here, do it by checking
> > ->rx_handler pointer.
> > 
> > Note that synchronize_net() in netdev_rx_handler_unregister() ensures
> > this approach as valid.
> > 
> > Introduced originally by:
> > commit f350a0a87374418635689471606454abc7beaa3a
> >   "bridge: use rx_handler_data pointer to store net_bridge_port pointer"
> > 
> > Fixed but not in the best way by:
> > commit b5ed54e94d324f17c97852296d61a143f01b227a
> >   "bridge: fix RCU races with bridge port"
> > 
> > Reintroduced by:
> > commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2
> >   "bridge: fix NULL pointer deref of br_port_get_rcu"
> > 
> > Please apply to stable trees as well. Thanks.
> > 
> > RH bugzilla reference: https://bugzilla.redhat.com/show_bug.cgi?id=1025770
> > 
> > Reported-by: Laine Stump <laine@redhat.com>
> > Debugged-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> > ---
> > v1->v2: moved br_port_get_check_rcu definition below br_handle_frame definition
> 
> Applied and queued up for -stable, thanks Jiri.

How come you ignored my simpler fix, that used the existing logic.
I don't like introducing this especially into the stable; much prefer
to go back to testing the flag as was being done before.
