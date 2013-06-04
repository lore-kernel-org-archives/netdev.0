From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: bridge: fix 'bridge link'
 setlink/getlink parsing
Date: Mon, 3 Jun 2013 19:57:19 -0700
Message-ID: <20130603195719.34d21480@nehalam.linuxnetplumber.net>
References: <20130529162044.25906.79115.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130529162044.25906.79115.stgit@nitbit.x32>
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

On Wed, 29 May 2013 09:20:53 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> Use IFLA_AF_SPEC nested attributes to lookup bridge mode and when
> doing strcmp() check for equality.
> 
> These appear to be typos from the original commit,
> 
> commit 64108901b737b95247b53dec8c1b8217ca8505b7
> Author: Vlad Yasevich <vyasevic@redhat.com>
> Date:   Fri Mar 15 10:01:28 2013 -0700
> 
>     bridge: Add support for setting bridge port attributes
> 
> Also set flags to BRIDGE_FLAGS_SELF instead of using OR operation.
> This allows setting the bridge mode when not being used with a
> master device.
> 
> To allow setting both master and self devices simultaneously we
> will need to add a {self|master} field similar to fdb commands.
> For now the command sets are mutually exclusive as noted in the
> original commit.
> 
> With this patch 'bridge link set' works now,
> 
> # ./bridge/bridge link set dev veth1 cost 3
> # ./bridge/bridge link show
> 10: veth1 state UP : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master bridge0 state forwarding priority 3 cost 3
> 
> CC: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Looks good, applied
