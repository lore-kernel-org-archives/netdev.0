From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 29 Nov 2007 11:00:46 +0100
Message-ID: <200711291100.46598.ak@suse.de>
References: <20071122343.446909000@suse.de> <200711291055.02056.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:59176 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757315AbXK2KAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 05:00:50 -0500
In-Reply-To: <200711291055.02056.arnd@arndb.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I think it would be good if you could specify a default namespace
> per module, that could reduce the amount of necessary changes significantly.

But also give less documentation. It's also not that difficult to mark
the exports once. I've forward ported such patches over a few kernels
and didn't run into significant me

> obj-$(CONFIG_COMBINED) += combined.o
> combined-$(CONFIG_SUBOPTION) += combined_main.o combined_other.o
> obj-$(CONFIG_SINGLE) += single.o
> obj-$(CONFIG_OTHER) += other.o
> obj-$(CONFIG_API) += api.o
> 
> NAMESPACE = subsys                       # default, used for other.o
> NAMESPACE_single.o = single              # used only for single.o
> NAMESPACE_combined.o = combined          # all parts of combined.o
> NAMESPACE_combined_other.o = special     #    except this one
> NAMESPACE_api.o =                        # api.o is put into the global ns

I would prefer to keep that inside the source files, again for 
documentation purposes. One goal of namespace was to make something
that was previously kind of implicit explicit and the default name
spaces would work against that again I think.

-Andi
 
