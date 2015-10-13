From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [bug report or not] ping6 will lost packets when ping6 lots of
 ipv6 address
Date: Tue, 13 Oct 2015 09:11:45 -0700
Message-ID: <20151013161145.GE88112@canlin-mbp1.DHCP.thefacebook.com>
References: <CAJFZqHwASEOG-atD=yvygra=Ah5awF+9drmgGZm7L2OoGam0DQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:15721 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932369AbbJMQLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 12:11:51 -0400
Content-Disposition: inline
In-Reply-To: <CAJFZqHwASEOG-atD=yvygra=Ah5awF+9drmgGZm7L2OoGam0DQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 08:46:49PM +0800, Li RongQing wrote:
> 1. in a machine, configure 3000 ipv6 address in one interface
>
> for i in {1..3000}; do ip -6 addr add 4001:5013::$i/0 dev eth0; done
>
>
> 2. in other machine, ping6 the upper configured ipv6 address, then
> lots of lost packets
>
> ip -6 addr add 4001:5013::0/64 dev eth0
> for i in {1..2000}; do ping6 -q -c1 4001:5013::$i; done;
>
> 3. increasing the gc thresh can handles these lost
>
> sysctl -w  net.ipv6.neigh.default.gc_thresh1=2000
> sysctl -w  net.ipv6.neigh.default.gc_thresh2=3000
> sysctl -w  net.ipv6.neigh.default.gc_thresh3=4000
> sysctl -w net.ipv6.route.gc_thresh=3000
> sysctl -w net.ipv6.route.max_size =3000
Which kernel is used in this test?
