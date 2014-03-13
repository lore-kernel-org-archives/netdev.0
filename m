From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 2/3] bridge: trigger a bridge calculation upon
	port changes
Date: Thu, 13 Mar 2014 11:26:25 -0700
Message-ID: <CAHA+R7Pf6rM5h1uGiqrru5LkN9C7Nm7V42cucHSOV1s7_+F7Gw@mail.gmail.com>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
	<1394680527-28970-3-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>, mcgrof@suse.com,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1394680527-28970-3-git-send-email-mcgrof@do-not-panic.com>
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

On Wed, Mar 12, 2014 at 8:15 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
>                         spin_lock_bh(&p->br->lock);
>                         err = br_setport(p, tb);
> +                       changed = br_stp_recalculate_bridge_id(p->br);

Looks like you only want to check if the mac addr gets changed here,
but br_stp_recalculate_bridge_id() does more than just checking it,
are you sure the side-effects are all what you want here?

>                         spin_unlock_bh(&p->br->lock);
> +                       if (changed)
> +                               call_netdevice_notifiers(NETDEV_CHANGEADDR,
> +                                                        p->br->dev);
> +                       netdev_update_features(p->br->dev);

I think this is supposed to be in netdev event handler of br->dev
instead of here.
