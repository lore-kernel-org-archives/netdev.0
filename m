From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next v2 02/19] i40e: simplify txd use count calculation
Date: Wed, 07 Dec 2016 17:03:32 -0800
Message-ID: <1481159012.4930.85.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
         <20161207221918.57932-3-jeffrey.t.kirsher@intel.com>
         <1481156184.4930.77.camel@edumazet-glaptop3.roam.corp.google.com>
         <B1C1DF2ACD01FD4881736AA51731BAB2A54ADC@ORSMSX107.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "guru.anbalagane@oracle.com" <guru.anbalagane@oracle.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34202 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752807AbcLHBEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 20:04:20 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so24992816pgc.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 17:03:35 -0800 (PST)
In-Reply-To: <B1C1DF2ACD01FD4881736AA51731BAB2A54ADC@ORSMSX107.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-08 at 00:35 +0000, Duyck, Alexander H wrote:

> Well there ends up being a few aspects to it.  First we don't need the
> precision of a full 64b inverse multiplication, that is why we can get
> away with multiple by 85 and shift.  The assumption is we should never
> see a buffer larger than 64K for a TSO frame.  That being the case we
> can do the same thing without having to use a 64b value which isn't an
> option on 32b architectures.
> 
> So basically what it comes down to is dealing with the "optimized for
> size" kernel option, and 32b architectures not being able to do this.
> Arguably both are corner cases but better to deal with them than take
> a performance hit we don't have to.

ok ok ;)

Too bad the 65536 value is accepted, (is it ?) otherwise

unsigned int foo(unsigned short size)
{
	return size / 0x3000;
}

-> generates the same kind of instructions, with maybe a better
precision.

foo:
	movzwl	%di, %eax
	imull	$43691, %eax, %eax
	shrl	$29, %eax
	ret
