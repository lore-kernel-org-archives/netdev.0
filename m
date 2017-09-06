From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Wed, 6 Sep 2017 19:03:54 +0800
Message-ID: <20170906110354.GA111355@cran64.bj.intel.com>
References: <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<20170904023831.GA68062@cran64.bj.intel.com>
	<87mv6abte5.fsf@stressinduktion.org>
	<20170905021112.GA86057@cran64.bj.intel.com>
	<87vakxsaj2.fsf@stressinduktion.org>
	<20170905113848.GC92895@cran64.bj.intel.com>
	<878thtmgra.fsf@stressinduktion.org>
	<20170906005359.GA103260@cran64.bj.intel.com>
	<87o9qo9ru6.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87o9qo9ru6.fsf-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 06, 2017 at 04:03:29PM +0800, Hannes Frederic Sowa wrote:
> "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
> >> 
> >> > If you check GENEVE implementation, tun_metadata* can be set or matched
> >> > as any other match field.
> >> 
> >> Yes, I wrote that in my previous mail. I wonder why NSH context metadata
> >> is not in tun_metadata as well?
> >
> > tun_metadata is tunnel metadata, GENEVE needs tunnel port, but NSH is
> > not so, NSH can't directly use tun_metadata, for MD type 2, we need to a
> > lot of rework on tun_metadata to make it shared between GENEVE and NSH,
> > I don't think this can happen in near term. So tun_metadata isn't option
> > for this now.
> 
> Sorry, I couldn't follow you. Why can't you store the context headers in
> tun_metadata exactly?

tun_metadata can work only if in_port and out_port are GENEVE tunnel
port, it is designed specially for GENEVE, Eth+NSH can work without
any tunnel port involved, context headers for NSH are not tunnel
metadata, they aren't tunnel-specific, you can't treat them as same
thing. In addtition, tun_metadata also can be matched and set, they have
the same issue as you concern.

> 
> [...]
> 
> Bye,
> Hannes
