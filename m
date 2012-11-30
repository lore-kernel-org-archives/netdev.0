From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net-next:master 98/98]
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to
 restricted __be16
Date: Sat, 1 Dec 2012 06:02:28 +0800
Message-ID: <20121130220228.GA22050@localhost>
References: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com>
 <50B92A6D.8000600@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Christopher Li <sparse@chrisli.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27721 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755962Ab2K3WCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 17:02:35 -0500
Content-Disposition: inline
In-Reply-To: <50B92A6D.8000600@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2012 at 04:51:41PM -0500, Andrew Gallatin wrote:
> On 11/30/12 16:02, kbuild test robot wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> > head:   1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2
> > commit: 1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2 [98/98] myri10ge: Add vlan rx for better GRO perf.
> > 
> > 
> > sparse warnings:
> > 
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:16: sparse: restricted __be16 degrades to integer
> 
> 
> OK, maybe a dumb question again, but how do I get sparse to produce
> the 'cast to restricted' warnings?
[snip]
> Also, the line it is warning about is this:
> 
> > 1b4c44e6 Andrew Gallatin 2012-11-30 @1286  	    veh->h_vlan_proto == ntohs(ETH_P_8021Q)) {
> 
> 
> Which seems to be nearly identical to the usage in
> if_vlan.h:__vlan_get_tag, which I was treating as canonical..
> So I'm a bit confused as to how to fix it.
 
Andrew, here is the explanations from Christopher Li:

On Thu, Nov 29, 2012 at 09:58:58AM -0800, Christopher Li wrote:
> On Wed, Nov 28, 2012 at 2:42 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 28 Nov 2012 17:23:47 +0800
> >>
> >> + fs/hfsplus/xattr.c:363:23: sparse: cast to restricted __be32
> 
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  361   hfs_bnode_read(fd.bnode, &record_type,
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  362                   fd.entryoffset, sizeof(record_type));
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27 @363   record_type = be32_to_cpu(record_type);
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  364   if (record_type == HFSPLUS_ATTR_INLINE_DATA) {
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  365           record_length = hfs_bnode_read_u16(fd.bnode,
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  366                           fd.entryoffset +
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  367                           offsetof(struct hfsplus_attr_inline_data,
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  368                           length));
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  369           if (record_length > HFSPLUS_MAX_INLINE_DATA_SIZE) {
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  370                   printk(KERN_ERR "hfs: invalid xattr record size\n");
> >> 54d776ef Vyacheslav Dubeyko 2012-11-27  371                   res = -EIO;
> >>
> >
> > I don't know what that warning means :(
> 
> Who does any way :-).
> 
> >
> > Chris, can you shed some light here?
> 
> I think it is likely cause by record_type get value assigned.
> What you want here is have one variable for record_type store in back
> end endian.
> Then have a different variable to store the record_type in CPU endian.
> It is bad idea to store both endian in the same variable. That is what sparse is
> complaining right now.
> 
> The detail cause of the complain is that, record_type has type __be32 __u32.
> After be32_to_cpu() it return __u32 type.
> When you assign __u32 type to a __be32_u32, sparse find out it has
> type mismatch,
> so it will do implicitly up cast. Think about if you assign char
> variable to int, the compiler
> will need to insert a cast to do the sign extension. That case is
> causing the error message
> because __be32 can't be cased.
> 
> Any way, it seems sparse is doing what it suppose to do here. The suggested
> way to fix the warning is give different variable for back end and
> CPU. That should get rid
> of the warning.
> 
> Chris
