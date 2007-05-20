From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1
Date: Sun, 20 May 2007 12:03:08 -0700
Message-ID: <46509B6C.2070604@intel.com>
References: <E1Hpj4l-0006lF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cebbert@redhat.com, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60407 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755451AbXETTDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 May 2007 15:03:34 -0400
In-Reply-To: <E1Hpj4l-0006lF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>>> The source file has four extra lines at the top because of a
>>> trivial wireless patch, so 898 in that code is really 894 in
>>> the stock kernel.
>> please shared that code then.
> 
> I've had a look and e1000 is definitely buggy.
> 
> The problem is that you're calling netif_poll_enable on startup.
> This is *wrong*.
> 
> netif_poll_enable can only be called if you've previously called
> netif_poll_disable.  Otherwise a poll might already be in action
> and you may get a crash like this.
> 
> So perhaps you should divide e1000_up into two sections, one that
> is called on both start and restart and another which is only
> called on restart (i.e., after e1000_down).

OK, that would explain the recent frenzy of reports in this matter. That code 
was only recently merged. I will dig into this and get a patch out as soon as I 
can so you can test this.

Thanks Herbert.

Auke
