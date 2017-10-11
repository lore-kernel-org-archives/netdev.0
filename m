From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [RFC net-next 4/4] mlxsw: spectrum_router: Add extack message
 for RIF and VRF overflow
Date: Wed, 11 Oct 2017 18:10:43 +0300
Message-ID: <20171011151043.GA13708@splinter>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-5-git-send-email-dsahern@gmail.com>
 <20171011141330.GC11653@splinter>
 <72ad213d-7074-e4ca-6799-94da01c38f8e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com,
        kjlx@templeofstupid.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58225 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750970AbdJKPKq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 11:10:46 -0400
Content-Disposition: inline
In-Reply-To: <72ad213d-7074-e4ca-6799-94da01c38f8e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 09:07:20AM -0600, David Ahern wrote:
> On 10/11/17 8:13 AM, Ido Schimmel wrote:
> > On Tue, Oct 10, 2017 at 09:41:05AM -0700, David Ahern wrote:
> >>  static struct mlxsw_sp_vr *mlxsw_sp_vr_create(struct mlxsw_sp *mlxsw_sp,
> >> -					      u32 tb_id)
> >> +					      u32 tb_id,
> >> +					      struct netlink_ext_ack *extack)
> >>  {
> >>  	struct mlxsw_sp_vr *vr;
> >>  	int err;
> >>  
> >>  	vr = mlxsw_sp_vr_find_unused(mlxsw_sp);
> >> -	if (!vr)
> >> +	if (!vr) {
> >> +		NL_SET_ERR_MSG(extack, "spectrum: Exceeded number of supported VRF");
> > 
> > Maybe:
> > "spectrum: Exceeded number of supported VRF devices"
> 
> In this context the overflow is virtual routers in spectrum as opposed
> to VRF devices in the kernel context. The existence of the VRF device
> has no bearing until a port is enslaved to it.
> 
> How about:
>  "spectrum: Exceeded number of supported virtual routers"

OK.
