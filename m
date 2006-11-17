From: Bryan O'Sullivan <bos@pathscale.com>
Subject: Re: [openib-general] [PATCH  09/13] Core WQE/CQE Types
Date: Fri, 17 Nov 2006 10:19:15 -0800
Message-ID: <455DFD23.8050504@pathscale.com>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int> <20061116035912.22635.21736.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.pathscale.com ([64.160.42.68]:9178 "EHLO mx.pathscale.com")
	by vger.kernel.org with ESMTP id S1755514AbWKQSS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 13:18:57 -0500
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20061116035912.22635.21736.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> T3 WQE and CQE structures, defines, etc...

I notice that none of the fields in these structs seem to be 
endianness-annotated, but that there's a lot of cpu_to_be64 and so on 
being used to frob values into them.  Please make sure that the driver 
passes a sparse check, which it looks like it almost certainly cannot 
right now.

> +#define RING_DOORBELL(doorbell, QPID) { \
> +	(writel(((1<<31) | (QPID)), doorbell)); \
> +}

Should probably be an inline function instead of a macro.

	<b
