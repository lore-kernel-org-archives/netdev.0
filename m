From: "Varlese, Marco" <marco.varlese@intel.com>
Subject: RE: [RFC PATCH net-next 1/1] net: Support for switch port
 configuration
Date: Fri, 12 Dec 2014 09:19:55 +0000
Message-ID: <C4896FB061E7DE4AAC93031BDCA044B104AC4609@IRSMSX108.ger.corp.intel.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com>
 <20141210165018.GG1863@nanopsycho.orion> <54887CF7.70708@gmail.com>
 <C4896FB061E7DE4AAC93031BDCA044B104AC3914@IRSMSX108.ger.corp.intel.com>
 <20141211110115.GA1979@nanopsycho.lan>
 <5489C85A.5020400@cumulusnetworks.com>
 <20141211165627.GF1912@nanopsycho.orion>
 <5489D739.9010303@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5489D739.9010303@cumulusnetworks.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
> Sent: Thursday, December 11, 2014 5:41 PM
> To: Jiri Pirko
> Cc: Varlese, Marco; John Fastabend; netdev@vger.kernel.org;
> stephen@networkplumber.org; Fastabend, John R; sfeldma@gmail.com;
> linux-kernel@vger.kernel.org
> Subject: Re: [RFC PATCH net-next 1/1] net: Support for switch port
> configuration
> 
> On 12/11/14, 8:56 AM, Jiri Pirko wrote:
> > Thu, Dec 11, 2014 at 05:37:46PM CET, roopa@cumulusnetworks.com wrote:
> >> On 12/11/14, 3:01 AM, Jiri Pirko wrote:
> >>> Thu, Dec 11, 2014 at 10:59:42AM CET, marco.varlese@intel.com wrote:
> >>>>> -----Original Message-----
> >>>>> From: John Fastabend [mailto:john.fastabend@gmail.com]
> >>>>> Sent: Wednesday, December 10, 2014 5:04 PM
> >>>>> To: Jiri Pirko
> >>>>> Cc: Varlese, Marco; netdev@vger.kernel.org;
> >>>>> stephen@networkplumber.org; Fastabend, John R;
> >>>>> roopa@cumulusnetworks.com; sfeldma@gmail.com; linux-
> >>>>> kernel@vger.kernel.org
> >>>>> Subject: Re: [RFC PATCH net-next 1/1] net: Support for switch port
> >>>>> configuration
> >>>>>
> >>>>> On 12/10/2014 08:50 AM, Jiri Pirko wrote:
> >>>>>> Wed, Dec 10, 2014 at 05:23:40PM CET, marco.varlese@intel.com
> wrote:
> >>>>>>> From: Marco Varlese <marco.varlese@intel.com>
> >>>>>>>
> >>>>>>> Switch hardware offers a list of attributes that are
> >>>>>>> configurable on a per port basis.
> >>>>>>> This patch provides a mechanism to configure switch ports by
> >>>>>>> adding an NDO for setting specific values to specific attributes.
> >>>>>>> There will be a separate patch that extends iproute2 to call the
> >>>>>>> new NDO.
> >>>>>> What are these attributes? Can you give some examples. I'm asking
> >>>>>> because there is a plan to pass generic attributes to switch
> >>>>>> ports replacing current specific ndo_switch_port_stp_update. In
> >>>>>> this case, bridge is setting that attribute.
> >>>>>>
> >>>>>> Is there need to set something directly from userspace or does it
> >>>>>> make rather sense to use involved bridge/ovs/bond ? I think that
> >>>>>> both will be needed.
> >>>>> +1
> >>>>>
> >>>>> I think for many attributes it would be best to have both. The in
> >>>>> kernel callers and netlink userspace can use the same driver ndo_ops.
> >>>>>
> >>>>> But then we don't _require_ any specific bridge/ovs/etc module.
> >>>>> And we may have some attributes that are not specific to any
> >>>>> existing software module. I'm guessing Marco has some examples of
> these.
> >>>>>
> >>>>> [...]
> >>>>>
> >>>>>
> >>>>> --
> >>>>> John Fastabend         Intel Corporation
> >>>> We do have a need to configure the attributes directly from user-space
> and I have identified the tool to do that in iproute2.
> >>>>
> >>>> An example of attributes are:
> >>>> * enabling/disabling of learning of source addresses on a given
> >>>> port (you can imagine the attribute called LEARNING for example);
> >>>> * internal loopback control (i.e. LOOPBACK) which will control how
> >>>> the flow of traffic behaves from the switch fabric towards an
> >>>> egress port;
> >>>> * flooding for broadcast/multicast/unicast type of packets (i.e.
> >>>> BFLOODING, MFLOODING, UFLOODING);
> >>>>
> >>>> Some attributes would be of the type enabled/disabled while other will
> allow specific values to allow the user to configure different behaviours of
> that feature on that particular port on that platform.
> >>>>
> >>>> One thing to mention - as John stated as well - there might be some
> attributes that are not specific to any software module but rather have to do
> with the actual hardware/platform to configure.
> >>>>
> >>>> I hope this clarifies some points.
> >>> It does. Makes sense. We need to expose this attr set/get for both
> >>> in-kernel and userspace use cases.
> >>>
> >>> Please adjust you patch for this. Also, as a second patch, it would
> >>> be great if you can convert ndo_switch_port_stp_update to this new
> ndo.
> >> Why are we exposing generic switch attribute get/set from userspace
> >> ?. We already have specific attributes for learning/flooding which
> >> can be extended further.
> > Yes, but that is for PF_BRIDGE and bridge specific attributes. There
> > might be another generic attrs, no?
> I cant think of any. And plus, the whole point of switchdev l2 offloads was to
> map these to existing bridge attributes. And we already have a match for
> some of the attributes that marco wants.
> 
> If there is a need for such attributes, i don't see why it is needed for switch
> devices only.
> It is needed for any hw (nics etc). And, a precedence to this is to do it via
> ethtool.
> 
> Having said that, am sure we will find a need for this in the future.
> And having a netlink attribute always helps.
> 
> Today, it seems like these can be mapped to existing attributes that are
> settable via ndo_bridge_setlink/getlink.
> 
> >
> >> And for in kernel api....i had a sample patch in my RFC series (Which
> >> i was going to resubmit, until it was decided that we will use
> >> existing api around
> >> ndo_bridge_setlink/ndo_bridge_getlink):
> >> http://www.spinics.net/lists/netdev/msg305473.html
> > Yes, this might become handy for other generic non-bridge attrs.
> >
> >> Thanks,
> >> Roopa
> >>
> >>
> >>

The list I provided is only a subset of the attributes we will need to be exposed. I do have more and I'm sure that more will come in the future. As I mentioned in few posts earlier, some attributes are generic and some are not. 

I did not consider ethtool for few reasons but the main one is that I was under the impression that netlink was preferred in many circumstances over the ethotool_ops. Plus, all the cases I have identified so far are going to nicely fit into the setlink set of operations.
