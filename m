From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 13:46:02 -0700
Message-ID: <1408049162.6804.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53ECFDAB.5010701@intel.com>
	 <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53ED1516.6020801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:51425 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbaHNUqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 16:46:04 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so2184131pdb.19
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 13:46:03 -0700 (PDT)
In-Reply-To: <53ED1516.6020801@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 12:59 -0700, Rick Jones wrote:

> Presumably, the -T $i,$j option in Alex's netperf command lines will 
> have bound netperf and netserver to a specific CPU where they will have 
> remained.

Thats the problem.

Softirq are receiving packets from other cpus. (RX queue X is handling
packets and one cpu is generally draining RX queue X and feed stack with
packets)

With RFS, RX path of IP and TCP stack would been handled by cpu Y (where
user thread is bound)
