From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC] bpf: remove global verifier state
Date: Wed, 4 Oct 2017 15:40:34 -0700
Message-ID: <20171004224032.zofzqj7zzmrvn4gf@ast-mbp.dhcp.thefacebook.com>
References: <20171003201452.elth55atpquesjjk@ast-mbp.dhcp.thefacebook.com>
 <20171004002025.28521-1-jakub.kicinski@netronome.com>
 <20171004025226.wutfwm6hcsj4zuph@ast-mbp>
 <1507087446.8061.37.camel@edumazet-glaptop3.roam.corp.google.com>
 <20171004034311.t3uba7vqcvahly2q@ast-mbp>
 <59D532EB.4000104@iogearbox.net>
 <20171004145744.27c08d4a@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>, dsahern@gmail.com,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        david.beckett@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35182 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdJDWkh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 18:40:37 -0400
Received: by mail-pg0-f66.google.com with SMTP id p5so12021383pgn.2
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 15:40:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171004145744.27c08d4a@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 02:57:44PM -0700, Jakub Kicinski wrote:
> On Wed, 04 Oct 2017 21:13:47 +0200, Daniel Borkmann wrote:
> > On 10/04/2017 05:43 AM, Alexei Starovoitov wrote:
> > > On Tue, Oct 03, 2017 at 08:24:06PM -0700, Eric Dumazet wrote:  
> > >> On Tue, 2017-10-03 at 19:52 -0700, Alexei Starovoitov wrote:
> > >>  
> > >>> yep. looks great.
> > >>> Please test it and submit officially :)
> > >>> The commit aafe6ae9cee3 ("bpf: dynamically allocate digest scratch buffer")
> > >>> fixed the other case where we were relying on the above mutex.
> > >>> The only other spot to be adjusted is to add spin_lock/mutex or DO_ONCE() to
> > >>> bpf_get_skb_set_tunnel_proto() to protect md_dst init.
> > >>> imo that would be it.
> > >>> Daniel, anything else comes to mind?  
> > 
> > Yes, this should be all. DO_ONCE() for the tunnel proto seems a
> > good choice.
> 
> Hm.  I actually did:
> 
> if (!dst) {
> 	tmp = alloc();
> 	if (!tmp)
> 		return;
> 	if (cmpxchg(&dst, NULL, tmp))
> 		free(tmp);
> }
> 
> I don't like how DO_ONCE() doesn't handle errors from the init
> function :(

yeah. good point.
Above looks good to me.
