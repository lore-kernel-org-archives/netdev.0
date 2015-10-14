From: Phil Sutter <phil@nwl.cc>
Subject: Re: NULL pointer dereference in rt6_get_cookie()
Date: Thu, 15 Oct 2015 00:34:13 +0200
Message-ID: <20151014223314.C029E20077@mail.nwl.cc>
References: <20151010132437.GB25926@orbit.nwl.cc>
 <20151013181443.GB68583@kafai-mba.local>
 <20151013191039.GA3070@base.sg13b.nwl.cc>
 <20151013192543.06B5021398@mail.nwl.cc>
 <20151014061421.GD68583@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46946 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752677AbbJNWdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 18:33:17 -0400
Content-Disposition: inline
In-Reply-To: <20151014061421.GD68583@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

On Tue, Oct 13, 2015 at 11:14:21PM -0700, Martin KaFai Lau wrote:
> On Tue, Oct 13, 2015 at 09:26:41PM +0200, Phil Sutter wrote:
> > I have backed up the rt pointer at top of the function and restored it
> > before pr_err, this is the output:
> >
> > | rt6i_dst:2001:4dd0:ff3b:13::/64 rt6i_gateway::: rt6i_flags:40000001 dst.flags:00000000
> Hi Phil, Can you try the following patch and report the pr_err?

Probably needless to say, but with your patch applied the Oops does not
occur anymore. This is the log output:

| [   46.518869] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   46.518874] IPv6:  rt:ffff8800cb07a000 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   46.529171] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   46.529174] IPv6:  rt:ffff8800cb07b500 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   46.529187] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   46.529189] IPv6:  rt:ffff8800cb07ad80 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   47.532014] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   47.532021] IPv6:  rt:ffff8800cb07a000 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   47.532028] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   47.532031] IPv6:  rt:ffff8800cb07b500 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   49.536010] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   49.536014] IPv6:  rt:ffff8800cb07ad80 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   49.536021] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   49.536024] IPv6:  rt:ffff8800cb07a180 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   53.544013] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   53.544020] IPv6:  rt:ffff8800cb07a300 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
| [   53.544028] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
| [   53.544031] IPv6:  rt:ffff8800cb07b980 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000

In case the amount of log entries is surprising: my test-case is
mounting two NFS shares over IPsec. No idea if that's relevant or not.

Cheers, Phil
