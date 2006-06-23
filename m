From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: ixgb EEH/PCI errors on reset
Date: Fri, 23 Jun 2006 16:33:39 -0500
Message-ID: <20060623213339.GR8866@austin.ibm.com>
References: <20060623170958.GN8866@austin.ibm.com> <Pine.WNT.4.63.0606231258110.3548@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	cramerj <cramerj@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:41915 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1752081AbWFWVdo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 17:33:44 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5NLXehh023586
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 17:33:40 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5NLXr8Y130506
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 15:33:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5NLXeW1008342
	for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 15:33:40 -0600
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0606231258110.3548@jbrandeb-desk.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 01:15:53PM -0700, Brandeburg, Jesse wrote:
> > fails in an unexpected way.  The last call invokes ixgb_mac_reset()
> > which writes a reset bit, delays a few millisecs, and reads the reset
> > bit.  The problem I'm seeing is that the read
> > 
> >   ctrl_reg = IXGB_READ_REG(hw, CTRL0);
> > 
> > triggers some PCI bus error that off-lines the device. Any hints
> 
> try this patch?  it is compile tested.

[...]

>  	IXGB_WRITE_REG(hw, EECD, *eecd_reg);
> +	IXGB_WRITE_FLUSH(hw);
>  	udelay(50);

With such a response, I had high hopes that the patch would work. 
Alas, it didn't help. I am in the process of rolling back to 
the driver v 1.0.100, which doesn'thave the problem, to see 
if I can isolate what changed.

--linas
