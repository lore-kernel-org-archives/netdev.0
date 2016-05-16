From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH nf-next] netfilter: allow logging from non-init
	namespaces
Date: Mon, 16 May 2016 08:43:16 +0200
Message-ID: <20160516064316.GA6455@unicorn.suse.cz>
References: <20160428074838.0BBB5A0C94@unicorn.suse.cz>
	<20160512095726.GA1975@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160512095726.GA1975@salvia>
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

On Thu, May 12, 2016 at 11:57:26AM +0200, Pablo Neira Ayuso wrote:
> Hi Michal,
> 
> On Wed, Apr 27, 2016 at 02:48:02PM +0200, Michal Kubecek wrote:
> > Commit 69b34fb996b2 ("netfilter: xt_LOG: add net namespace support for
> > xt_LOG") disabled logging packets using the LOG target from non-init
> > namespaces. The motivation was to prevent containers from flooding
> > kernel log of the host. The plan was to keep it that way until syslog
> > namespace implementation allows containers to log in a safe way.
> > 
> > However, the work on syslog namespace seems to have hit a dead end
> > somewhere in 2013 and there are users who want to use xt_LOG in all
> > network namespaces. This patch allows to do so by setting
> 
> I understand this stuff is tricky. Did you contact already namespace
> folks to see if they plan any move on this?

Not yet. I'll contact the people involved in the discussion about the
serires submitted in 2013 to check what their plans are (and if there
are any).

> >   /proc/sys/net/netfilter/nf_log_all_netns
> 
> My only concern with this is that I don't see how users know what log
> message has triggered from what container.

IMHO this is a more generic issue with containers: there is no (known to
me) link between userspace "containers" and kernel namespaces that could
be used in kernel log messages. In this case, --log-prefix can be used
in netfilter logging rules to identify the container messages belong to.

                                                          Michal Kubecek
