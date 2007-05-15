From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 15 May 2007 10:42:55 -0700
Message-ID: <4649F11F.3040807@zytor.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:54712 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758589AbXEORpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 13:45:03 -0400
In-Reply-To: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Badari Pulavarty wrote:
> Hi,
> 
> Is select(0, ..) is a valid operation ?
> 
> I see that there is no check to prevent this or return
> success early, without doing any work. Do we need one ?
> 
> slub code is complaining that we are doing kmalloc(0).
> 

select(0, ...) is valid, and is functionally equivalent to
select(..., NULL, NULL, NULL, ...); except that any nonzero fdsets get
zeroed on return.  As such, the only thing that can interrupt it is the
timeout, or a signal.

	-hpa
