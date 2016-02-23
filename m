From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] ipv4: in new netns initialize sysctls in
	net.ipv4.conf.* with defaults
Date: Tue, 23 Feb 2016 18:21:21 -0500 (EST)
Message-ID: <20160223.182121.2101846699151527296.davem@davemloft.net>
References: <20160221071102.9686.63148.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160221071102.9686.63148.stgit@buzz>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Date: Sun, 21 Feb 2016 10:11:02 +0300

> Currently initial net.ipv4.conf.all.* and net.ipv4.conf.default.* are
> copied from init network namespace because static structures are used
> for init_net. This makes no sense because new netns might be created
> from any netns. This patch makes private copy also for init netns if
> network namespaces are enabled. Other sysctls in net.ipv4 and net.ipv6
> already initialized with default values at namespace creation.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
> Fixes: 752d14dc6aa9 ("[IPV4]: Move the devinet pointers on the struct net")

The horse has long left the stable on this.  We cannot change this now
without breaking things.

Imagine someone who intentionally sets up init_net with a certain set
of settings and expects them to propagate into every created namespace.

We'll break things for them and given the behavior existed for so long
what the administrator is doing is very reasonable.

I'm not applying this sorry, we are stuck with the current behavior
whether we like it or not.
