From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: lost gARP after live migration
Date: Tue, 28 Jun 2011 15:14:15 +0100
Message-ID: <1309270455.3093.1579.camel@localhost>
References: <4E09D0A0.1080107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Paolo Bonzini <pbonzini@redhat.com>
To: Laszlo Ersek <lersek@redhat.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <4E09D0A0.1080107@redhat.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, 2011-06-28 at 15:01 +0200, Laszlo Ersek wrote:
[...]
> When the guest waits for about half a second before sending (queueing), 
> the very first gARP packet successfully appears on the host bridge.
> 
> I suspect it's a timing race against the netback vif being added to the 
> host bridge. What would be a good countermeasure?
> 
> - Adding two modparams to xen-netfront (gARP requeue count & number of 
> msecs to wait between queueing the gARPs).

Note that peer notifications are indirected through netdev notifiers and
now include IPv6 NAs as well as ARPs.  If repeated notifications are
commonly necessary then this should probably be handled in the protocol
(or in the networking core).  However this sounds like a workaround
whereas your other option would be a proper fix:

> - (Paolo's idea:) watching the "hotplug-status" xenstore node and 
> sending a single gARP when the watch fires with "connected". This node 
> belongs to the backend xenstore subtree, thus watching it from the guest 
> doesn't please the architecture astronaut in me.
[...]

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
