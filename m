From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/3] bridge: fix bridge root block on
	designated port
Date: Thu, 13 Mar 2014 15:16:23 -0700
Message-ID: <20140313151623.03e0484d@nehalam.linuxnetplumber.net>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
	<1394680527-28970-4-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, mcgrof@suse.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1394680527-28970-4-git-send-email-mcgrof@do-not-panic.com>
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

On Wed, 12 Mar 2014 20:15:27 -0700
"Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:

> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -150,6 +150,7 @@ struct net_bridge_port
>  	u8				priority;
>  	u8				state;
>  	u16				port_no;
> +	bool				root_block_enabled;
>  	unsigned char			topology_change_ack;

It seems a bit confusing to have both a ROOT_BLOCK flag in the
data structure and and additional root_block_enabled flag.
If nothing else it is a waste of space.

Looks like you are changing the meaning slightly. is possible
to have BR_ROOT_BLOCK set but !root_block_enabled? and what about
the inverse?
