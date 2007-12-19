From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Wed, 19 Dec 2007 11:31:25 +0000
Message-ID: <20071219113125.GF31508@nuim.ie>
References: <20071217134425.GD7409@nuim.ie> <20071218204022.GA8936@nuim.ie>
 <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:36755 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751537AbXLSLbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 06:31:22 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JTA00MXBO07QA40@mango.nuim.ie> for
 netdev@vger.kernel.org; Wed, 19 Dec 2007 11:31:19 +0000 (GMT)
In-reply-to: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 19 Dec 2007, Ilpo J=E4rvinen wrote:

> Isn't it also much better this way in a case where ACK losses happene=
d,
> taking the longest RTT in that case is clearly questionable as it
> may over-estimate considerably.

Quite so.

> However, another thing to consider is the possibility of this value b=
eing=20
> used in "timeout-like" fashion in ca modules (I haven't read enough c=
a=20
> modules code to know if any of them does that), on contrary to=20
> determinating just rtt or packet's delay in which case this change se=
ems=20
> appropriate (most modules do the latter).=20

I'm not aware of any, but I haven't read them all either.  I would have
thought tp->srtt was the value to use in this instance, but perhaps the
individual timestamps including delack delay are useful.

> Therefore, if timeout-like module exists one should also add
> TCP_CONG_RTT_STAMP_LONGEST for that particular module and keep using
> seq_rtt for it like previously and use ca_seq_rtt only for others.

Seems reasonable.  I'll add this.

> This part doesn't exists anymore in development tree. Please base thi=
s=20
> patch (and anything in future) you intend to get included to mainline
> onto net-2.6.25 unless there's a very good reason to not do so or=20
> whatever 2.6.xx is the correct net development tree at that time (if
> one exists). Thanks.

Will do.   I gather I should use the latest net- tree in future when
submitting patches.

Thanks for the helpful comments,

Gavin

