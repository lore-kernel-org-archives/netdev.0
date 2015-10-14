From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: NULL pointer dereference in rt6_get_cookie()
Date: Wed, 14 Oct 2015 16:17:05 -0700
Message-ID: <20151014231705.GA79022@kafai-mba.local>
References: <20151010132437.GB25926@orbit.nwl.cc>
 <20151013181443.GB68583@kafai-mba.local>
 <20151013191039.GA3070@base.sg13b.nwl.cc>
 <20151013192543.06B5021398@mail.nwl.cc>
 <20151014061421.GD68583@kafai-mba.local>
 <20151014223314.C029E20077@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:6930 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbbJNXRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 19:17:40 -0400
Content-Disposition: inline
In-Reply-To: <20151014223314.C029E20077@mail.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 15, 2015 at 12:34:13AM +0200, Phil Sutter wrote:
> Hi Martin,
>
> On Tue, Oct 13, 2015 at 11:14:21PM -0700, Martin KaFai Lau wrote:
> > On Tue, Oct 13, 2015 at 09:26:41PM +0200, Phil Sutter wrote:
> > > I have backed up the rt pointer at top of the function and restored it
> > > before pr_err, this is the output:
> > >
> > > | rt6i_dst:2001:4dd0:ff3b:13::/64 rt6i_gateway::: rt6i_flags:40000001 dst.flags:00000000
> > Hi Phil, Can you try the following patch and report the pr_err?
>
> Probably needless to say, but with your patch applied the Oops does not
> occur anymore. This is the log output:
Thanks for testing it.  The patch may need a bit refactoring work and
I will post it soon.

>
> | [   46.518869] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   46.518874] IPv6:  rt:ffff8800cb07a000 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   46.529171] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   46.529174] IPv6:  rt:ffff8800cb07b500 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   46.529187] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   46.529189] IPv6:  rt:ffff8800cb07ad80 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   47.532014] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   47.532021] IPv6:  rt:ffff8800cb07a000 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   47.532028] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   47.532031] IPv6:  rt:ffff8800cb07b500 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   49.536010] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   49.536014] IPv6:  rt:ffff8800cb07ad80 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   49.536021] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   49.536024] IPv6:  rt:ffff8800cb07a180 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   53.544013] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   53.544020] IPv6:  rt:ffff8800cb07a300 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
> | [   53.544028] IPv6: ort:ffff8800cbb5b800 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:40000001 dst.flags:00000020
> | [   53.544031] IPv6:  rt:ffff8800cb07b980 rt6i_dst:[2001:4dd0:ff3b:13::]/64 rt6i_gateway:[::] rt6i_flags:00000001 dst.flags:00000000
>
> In case the amount of log entries is surprising: my test-case is
> mounting two NFS shares over IPsec. No idea if that's relevant or not.
I also don't know why xfrm_lookup() errors out and then triggers
make_blackhole() but I believe it should not affect the fix here.

Thanks,
Martin
