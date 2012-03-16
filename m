From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ethtool: Added a field fw dump_state
Date: Fri, 16 Mar 2012 21:37:04 +0000
Message-ID: <1331933824.2504.22.camel@bwh-desktop.uk.solarflarecom.com>
References: <CB88F67C.2A1CE%anirban.chakraborty@qlogic.com>
	 <1331932962.19406.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35845 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756512Ab2CPVhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 17:37:08 -0400
In-Reply-To: <1331932962.19406.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-16 at 14:22 -0700, Eric Dumazet wrote:
> On Fri, 2012-03-16 at 14:10 -0700, Anirban Chakraborty wrote:
> > 
> > On 3/16/12 11:27 AM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
> > 
> > >On Fri, 2012-03-16 at 10:58 -0700, Anirban Chakraborty wrote:
> > >> +
> > >>  struct ethtool_dump {
> > >>  	__u32	cmd;
> > >>  	__u32	version;
> > >>  	__u32	flag;
> > >>  	__u32	len;
> > >>  	__u8	data[0];
> > >> +	__u8	dump_state;
> > >
> > >Don't be ridiculous.
> > 
> > Yeah I know, especially when there is a flag field already present there.
> > The only
> > reason, we considered for adding it is to keep the backward compatibility
> > of scripts.
> > Right now, the flag field sets/gets the dump level of fw. If we use it to
> > control the
> > dump state, then it would break the existing scripts, if there are any.
> > 
> 
> You missed the point... data[0] must be the last element in the
> structure.

Right.  And len is documented as not used by the ETHTOOL_SET_DUMP
command so we cannot say that when len == 1 then data[0] is this new
flag.

Just reserve some value of the flag to mean 'disable', say 0 or
0xffffffff.  If you want this 'disable' value to be understood by all
drivers and have ethtool support a keyword for it then also define a
macro for the value in ethtool.h.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
