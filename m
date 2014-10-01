From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a
 refcnt on port.
Date: Wed, 01 Oct 2014 13:15:26 -0700
Message-ID: <1412194526.16704.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001185622.GI17706@oracle.com>
	 <1412190324.16704.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141001194403.GM17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:47395 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaJAUPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:15:15 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so803190pdj.9
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 13:15:14 -0700 (PDT)
In-Reply-To: <20141001194403.GM17706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-01 at 15:44 -0400, Sowmini Varadhan wrote:
> On (10/01/14 12:05), Eric Dumazet wrote:
> > 
> > Hmpff... This calls for rcu protection here !
> > 
> 
> I did consider that, but given that the lists containing the ports are
> accessed in multiple contexts, some of which can sleep, and given that
> the vnet port is similar in spirit to the net_device, I followed the
> net_device model of dev_put etc.

dev_put() uses per cpu variables, an order of magnitude faster than a
atomic put/get :(
