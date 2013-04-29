From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH] Add support for netconsole driver used on bridge
 device with VIF attached
Date: Mon, 29 Apr 2013 13:42:25 +0300
Message-ID: <1367232145.26060.1.camel@yuval-pc>
References: <5757e54b-902b-4338-8ac9-43857cd1906c@default>
	 <50FD8243.6000501@oracle.com>
	 <1358846612.3279.282.camel@zakaz.uk.xensource.com>
	 <201301291054.46405.yuval.shaia@oracle.com>
	 <1359455385.12252.85.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43992 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab3D2Kmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 06:42:37 -0400
In-Reply-To: <1359455385.12252.85.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-29 at 10:29 +0000, Ian Campbell wrote:
> On Tue, 2013-01-29 at 08:54 +0000, Yuval Shaia wrote:
> > > Please can you explain the exact code path which results in this new
> > > hook being called.
> > > 
> > init_netconsole() in netconsole.c -> alloc_param_target() -> netpoll_setup() 
> > in netpoll.c -> __netpoll_setup() which check if ndo_poll_controller() 
> > operation is supported.
> 
> Are you sure this is being called for the VIF interface? In your
> configuration I'd expect it to be called on the bridge not the vif, or
> at least for calling on the VIF to not impact whether netpool was
> enabled for the bridge or not.
> 
> I think the underlying issue which you are seeing is that
> br_netpoll_setup() requires that all members of the bridge support
> netpoll before allowing netpoll to be enabled on the bridge itself. 
> 
> This seems like an odd restriction in the bridge driver since in
> principal only the port over which the netpoll traffic will be going
> will need netpoll, but perhaps the bridge can't tell which port that is
> or is going to be? I think it is worth discussing this with the bridge
> maintainers (who I have CC'd, threads starts at
> http://marc.info/?l=linux-netdev&m=135878868112700&w=2)
> 
> Hopefully the bridge isn't flooding/broadcasting netpoll to all ports,
> at least in the case where DST IP and MAC have been specified. That
> would be rather inefficient, especially when most ports go to virtual
> machines.
> 
> So before I ack this patch I'd like to hear back from the bridge
> maintainers about whether the current behaviour in the bridge is
> intended and whether it could be fixed in some better way than adding
> netpoll to netback.
Ian,
Can you suggest how to continue from here? as i don't see any comment on
that issue up to now.
Yuval
> 
> AFAICT the only reason to actually support netpoll in netback would be
> if you wanted host logs to go to a listener running in a domain on the
> same host, which sounds like a mad idea to me! If someone actually has a
> real need for that use case and can test that it works I'd be happy to
> reconsider this patch on that basis (assuming the necessary #ifdefs are
> added as mentioned before).
> 
> > > BTW looking at the patch as it is any use of this hook should be wrapped
> > > in CONFIG_NET_POLL_CONTROLLER.
> > > 
> > > Ian.
> > > 
> > 
> > 
> 
> 
