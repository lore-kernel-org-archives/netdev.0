From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge changes
 state
Date: Wed, 9 Mar 2011 23:09:49 +0800
Message-ID: <20110309150949.GE16951@cr0.redhat.com>
References: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Adam Majer <adamm@zombino.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 05, 2011 at 11:18:33PM -0600, Adam Majer wrote:
>
>IPv6 address autoconfiguration relies on an UP interface to processes
>traffic normally. A bridge that is UP enters LEARNING state and this
>state "eats" any Router Advertising packets sent to the
>bridge. Issuing a NETDEV_CHANGE notification on the bridge interface
>when it changes state allows autoconfiguration code to retry
>querying router information.
>
...

>+static void br_port_change_notifier_handler(struct work_struct *work)
>+{
>+	struct net_bridge *br = container_of(work,
>+					     struct net_bridge,
>+					     change_notification_worker);
>+
>+	rtnl_lock();
>+	netdev_state_change(br->dev);
>+	rtnl_unlock();
>+}
>+

Do you really want user-space to get this notification too?
Why do you put it into a workqueue? Maybe it has to be called in
process-context?

Thanks.
