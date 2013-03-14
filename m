From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 net-next 0/3] Allow bridge to function
 in non-promisc mode
Date: Thu, 14 Mar 2013 21:18:07 +0200
Message-ID: <20130314191807.GA30381@redhat.com>
References: <1362691728-13289-1-git-send-email-vyasevic@redhat.com>
	<20130307214304.25e7784e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130307214304.25e7784e@nehalam.linuxnetplumber.net>
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

On Thu, Mar 07, 2013 at 09:43:04PM -0800, Stephen Hemminger wrote:
> On Thu,  7 Mar 2013 16:28:45 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
> > The series adds an ability to configure the bridge into a non-primiscuous
> > mode.   Instead, it provides the ability to identitfy some set of bridge
> > ports as uplinks and allows for MAC addresses to be programmed onto
> > those ports.  In case the port hardware does not support mac filter,
> > that port will be placed in promiscuous mode.
> > 
> > Default bridge operation continues to remain as "promiscuous".  The new
> > functionality has to be enabled via sysfs (similar to other bridge extensions).
> > 
> > The uplink mode is implemented as a flag on a bridge port.  The api to
> > change that flag follows the existing api to enable/disable other existing
> > flags.
> > 
> > All comments are welcome.
> > 
> 
> Can we make this a one step process and less visible to the user.
> If user defines an uplink device, and the uplink device is capable of filtering
> (and what ever other pre-conditions people can think of), then the bridge will
> transparently switch to uplink/non-promisc mode.  This can also be used to trigger
> edge only mode in RSTP in the future.
> 
> Less knobs.
> 

Rephrasing what I suggested using 'uplink' term:
- add ability to specify wanted addresses on a port
- wheneever we don't specify addresses we call an uplink
  (either automatically so by default all
  ports are uplink, or add a separate flag - any preference?)
- if there are 0 uplinks, no ports are promisc
- if there is 1 uplink, it is not promisc but all others are promisc
- if there are >1 uplinks, everyone is promisc


> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
