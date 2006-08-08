From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Excess use of packed attribute
Date: Mon, 07 Aug 2006 17:02:08 -0700
Message-ID: <1154995328.11916.24.camel@w-sridhar2.beaverton.ibm.com>
References: <20060807133423.11bfbff3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:48779 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932374AbWHHAHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 20:07:11 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k78079wa015588
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 20:07:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k78079vq233284
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 20:07:09 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7807816028130
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 20:07:09 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060807133423.11bfbff3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-07 at 13:34 -0700, Stephen Hemminger wrote:
> After reading:
> 	http://bugzilla.kernel.org/show_bug.cgi?id=6693
> 
> I noticed there were stupid uses of packed attribute in several network headers.
> 
> Silly offenders:	include/net/ipx.h
> 			include/net/ieee80211.h
> 			include/net/ip6_tunnel.h
> 			include/net/ndisc.h
> 			include/linux/if_ether.h
> 			include/linux/if_fddi.h
> 		
> 			include/linux/sctp.h -- really bad

All the structures in sctp.h that use packed atrribute define
standard on-wire SCTP chunk/parameter formats. They need to be at the
exact offsets as they go on wire.
I think we saw some issues without the packed attribute on 64-bit archs
and just to be safe we added packed to all the on-wire structures.

Thanks
Sridhar

